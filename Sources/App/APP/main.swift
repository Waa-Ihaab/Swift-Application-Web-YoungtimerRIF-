// main.swift
// YoungtimerGarage — Projet Final iOS Swift
// Université Paris 8 — 2026

import Hummingbird
import NIOCore
import Foundation

// MARK: - Application Setup

/// Configure et lance le serveur Hummingbird 2.
///
/// Architecture :
///   GET  /                → liste toutes les voitures (+ tri optionnel via ?sort=)
///   GET  /search          → recherche par marque/modèle/couleur (?q=)
///   GET  /cars/:id        → page de détail d'une voiture [BONUS]
///   GET  /add             → formulaire d'ajout
///   GET  /edit/:id        → formulaire de modification pré-rempli
///   POST /create          → insère une nouvelle voiture
///   POST /update/:id      → met à jour une voiture existante
///   POST /delete/:id      → supprime une voiture

let app = Application(
    router: buildRouter(),
    configuration: .init(address: .hostname("0.0.0.0", port: 8080))
)

try await app.runService()

// MARK: - Router

/// Construit et retourne le routeur avec toutes les routes enregistrées.
func buildRouter() -> Router<BasicRequestContext> {
    let router = Router(context: BasicRequestContext.self)

    // ── GET / ──────────────────────────────────────────────────────────────
    // Liste toutes les voitures. Paramètre optionnel : ?sort=brand|year|price|mileage
    router.get("/") { request, context -> Response in
        let sortBy = request.uri.queryParameters.get("sort") ?? ""
        do {
            let cars = try DatabaseManager.shared.getAllCars(sortBy: sortBy.isEmpty ? nil : sortBy)
            let html = indexPage(cars: cars, searchQuery: "", sortBy: sortBy)
            return htmlResponse(html)
        } catch {
            let html = indexPage(cars: [], searchQuery: "", sortBy: "")
            return htmlResponse(html)
        }
    }

    // ── GET /search ────────────────────────────────────────────────────────
    // Recherche par marque, modèle ou couleur. Paramètre : ?q=
    router.get("/search") { request, context -> Response in
        let query = request.uri.queryParameters.get("q") ?? ""
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return redirect(to: "/")
        }
        do {
            let cars = try DatabaseManager.shared.searchCars(query: query)
            let html = searchPage(cars: cars, query: query)
            return htmlResponse(html)
        } catch {
            let html = searchPage(cars: [], query: query)
            return htmlResponse(html)
        }
    }

    // ── GET /cars/:id ──────────────────────────────────────────────────────
    // Page de détail d'une voiture. [BONUS +5 pts]
    router.get("/cars/:id") { request, context -> Response in
        guard let id = context.parameters.get("id", as: Int.self) else {
            return redirect(to: "/")
        }
        do {
            guard let car = try DatabaseManager.shared.getCar(id: id) else {
                return redirect(to: "/")
            }
            let html = detailPage(car: car)
            return htmlResponse(html)
        } catch {
            return redirect(to: "/")
        }
    }

    // ── GET /add ───────────────────────────────────────────────────────────
    // Affiche le formulaire d'ajout vide.
    router.get("/add") { request, context -> Response in
        let html = formPage()
        return htmlResponse(html)
    }

    // ── GET /edit/:id ──────────────────────────────────────────────────────
    // Affiche le formulaire pré-rempli pour modifier une voiture.
    router.get("/edit/:id") { request, context -> Response in
        guard let id = context.parameters.get("id", as: Int.self) else {
            return redirect(to: "/")
        }
        do {
            guard let car = try DatabaseManager.shared.getCar(id: id) else {
                return redirect(to: "/")
            }
            let html = formPage(car: car)
            return htmlResponse(html)
        } catch {
            return redirect(to: "/")
        }
    }

    // ── POST /create ───────────────────────────────────────────────────────
    // Reçoit le formulaire d'ajout, valide les données, insère en base.
    router.post("/create") { request, context -> Response in
        do {
            var body = try await request.body.collect(upTo: 1024 * 16)
            let raw  = body.readString(length: body.readableBytes) ?? ""
            let input = parseForm(raw)
            let car   = try input.validated()
            try DatabaseManager.shared.createCar(car)
            return redirect(to: "/")
        } catch let error as ValidationError {
            let html = formPage(error: error.description)
            return htmlResponse(html)
        } catch {
            let html = formPage(error: "Erreur lors de l'ajout : \(error)")
            return htmlResponse(html)
        }
    }

    // ── POST /update/:id ───────────────────────────────────────────────────
    // Reçoit le formulaire de modification, valide, met à jour en base.
    router.post("/update/:id") { request, context -> Response in
        guard let id = context.parameters.get("id", as: Int.self) else {
            return redirect(to: "/")
        }
        do {
            var body  = try await request.body.collect(upTo: 1024 * 16)
            let raw   = body.readString(length: body.readableBytes) ?? ""
            let input = parseForm(raw)
            let car   = try input.validated()
            try DatabaseManager.shared.updateCar(id: id, with: car)
            return redirect(to: "/cars/\(id)")
        } catch let error as ValidationError {
            let existingCar = try? DatabaseManager.shared.getCar(id: id)
            let html = formPage(car: existingCar, error: error.description)
            return htmlResponse(html)
        } catch {
            let existingCar = try? DatabaseManager.shared.getCar(id: id)
            let html = formPage(car: existingCar, error: "Erreur lors de la modification : \(error)")
            return htmlResponse(html)
        }
    }

    // ── POST /delete/:id ───────────────────────────────────────────────────
    // Supprime une voiture et redirige vers la liste.
    router.post("/delete/:id") { request, context -> Response in
        guard let id = context.parameters.get("id", as: Int.self) else {
            return redirect(to: "/")
        }
        do {
            try DatabaseManager.shared.deleteCar(id: id)
        } catch {
            // Si la voiture n'existe pas, on redirige quand même proprement.
        }
        return redirect(to: "/")
    }

    return router
}

// MARK: - Form Parser

/// Parse un body URL-encoded (ex: "brand=BMW&model=E30&year=1988")
/// et retourne un `CarFormInput` avec les valeurs décodées.
///
/// Les caractères spéciaux sont décodés via `removingPercentEncoding`.
/// Les `+` sont remplacés par des espaces (standard HTML form encoding).
func parseForm(_ raw: String) -> CarFormInput {
    var fields: [String: String] = [:]
    for pair in raw.split(separator: "&") {
        let parts = pair.split(separator: "=", maxSplits: 1)
        if parts.count == 2 {
            let key   = String(parts[0]).replacingOccurrences(of: "+", with: " ")
                            .removingPercentEncoding ?? String(parts[0])
            let value = String(parts[1]).replacingOccurrences(of: "+", with: " ")
                            .removingPercentEncoding ?? String(parts[1])
            fields[key] = value
        }
    }
    return CarFormInput(
        brand:     fields["brand"],
        model:     fields["model"],
        year:      fields["year"],
        mileage:   fields["mileage"],
        price:     fields["price"],
        color:     fields["color"],
        condition: fields["condition"]
    )
}

// MARK: - Response Helpers

/// Construit une réponse HTTP 200 avec du contenu HTML.
func htmlResponse(_ html: String) -> Response {
    var headers = HTTPFields()
    headers[.contentType] = "text/html; charset=utf-8"
    return Response(
        status: .ok,
        headers: headers,
        body: .init(byteBuffer: ByteBuffer(string: html))
    )
}

/// Construit une réponse HTTP 303 (redirect après POST).
func redirect(to path: String) -> Response {
    var headers = HTTPFields()
    headers[.location] = path
    return Response(status: .seeOther, headers: headers)
}
