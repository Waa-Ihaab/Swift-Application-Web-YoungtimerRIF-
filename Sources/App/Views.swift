////////////////////////////////////////////////////
//////////////////// KARI IHAB ////////////////////
//////////////////////////////////////////////////
/////////////////// Views cars //////////////////
//////////////////////////////////////////////////

import Foundation
import Hummingbird

// structure HTML - convertit une string en reponse HTTP
struct HTML: ResponseGenerator {
    let value: String
    func response(from request: Request, context: some RequestContext) throws -> Response {
        Response(
            status: .ok,
            headers: [.contentType: "text/html; charset=utf-8"],
            body: .init(byteBuffer: ByteBuffer(string: value))
        )
    }
}

struct Views {

    // layout de base avec navbar - toutes les pages utilisent ca
    static func layout(title: String, body: String, activePage: String = "cars") -> String {
        """
        <!DOCTYPE html>
        <html lang="fr" data-theme="dark">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>\(title)</title>
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css">
            <style>
                * { box-sizing: border-box; margin: 0; padding: 0; }

                body {
                    background-color: #111a11;
                    color: #ffffff;
                    font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                    min-height: 100vh;
                }

                /* ---- NAVBAR ---- */
                .navbar {
                    background-color: #1a2e1a;
                    border-bottom: 1px solid #2a4a2a;
                    padding: 0 2rem;
                    display: flex;
                    align-items: center;
                    justify-content: space-between;
                    height: 64px;
                    position: sticky;
                    top: 0;
                    z-index: 100;
                }
                .navbar-brand {
                    font-size: 1.2rem;
                    font-weight: 800;
                    color: #ffffff;
                    text-decoration: none;
                    display: flex;
                    align-items: center;
                    gap: 0.5rem;
                }
                .navbar-links {
                    display: flex;
                    gap: 0.5rem;
                }
                .nav-link {
                    padding: 0.5rem 1.2rem;
                    border-radius: 10px;
                    text-decoration: none;
                    font-size: 0.9rem;
                    font-weight: 500;
                    color: #aaaaaa;
                    transition: all 0.2s;
                }
                .nav-link:hover {
                    background-color: #2a4a2a;
                    color: #ffffff;
                }
                .nav-link.active {
                    background-color: #2d5a2d;
                    color: #ffffff;
                }
                .nav-link .badge {
                    background-color: #f0c040;
                    color: #111;
                    border-radius: 20px;
                    padding: 0.1rem 0.5rem;
                    font-size: 0.75rem;
                    font-weight: 700;
                    margin-left: 0.3rem;
                }

                /* ---- CONTAINER ---- */
                .container {
                    max-width: 680px;
                    margin: 0 auto;
                    padding: 2.5rem 1.5rem;
                }

                /* ---- HEADER PAGE ---- */
                .page-header {
                    margin-bottom: 2rem;
                }
                .page-header h1 {
                    font-size: 2rem;
                    font-weight: 800;
                    color: #ffffff;
                    margin-bottom: 0.3rem;
                }
                .page-header p {
                    color: #888888;
                    font-size: 0.85rem;
                }

                /* ---- BOUTON AJOUTER ---- */
                .add-btn {
                    display: inline-flex;
                    align-items: center;
                    gap: 0.4rem;
                    background-color: #2d5a2d;
                    color: #ffffff;
                    border: none;
                    border-radius: 12px;
                    padding: 0.75rem 1.4rem;
                    font-size: 0.95rem;
                    font-weight: 600;
                    cursor: pointer;
                    text-decoration: none;
                    margin-bottom: 1.5rem;
                    transition: background 0.2s;
                }
                .add-btn:hover { background-color: #3a7a3a; }

                /* ---- CARDS VOITURES ---- */
                .car-card {
                    background-color: #1a2e1a;
                    border: 1px solid #2a4a2a;
                    border-radius: 16px;
                    padding: 1.2rem 1.5rem;
                    margin-bottom: 0.8rem;
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    transition: border-color 0.2s;
                }
                .car-card:hover { border-color: #3a6a3a; }
                .car-card.is-favorite {
                    border-color: #f0c040;
                    background-color: #1e2e10;
                }
                .car-info h3 {
                    font-size: 1rem;
                    font-weight: 700;
                    color: #ffffff;
                    margin-bottom: 0.3rem;
                }
                .car-info p {
                    font-size: 0.82rem;
                    color: #888888;
                }
                .car-actions {
                    display: flex;
                    gap: 0.5rem;
                    align-items: center;
                    flex-shrink: 0;
                }
                .btn-star {
                    font-size: 1.4rem;
                    background: none;
                    border: none;
                    cursor: pointer;
                    padding: 0.2rem;
                    line-height: 1;
                    transition: transform 0.15s;
                }
                .btn-star:hover { transform: scale(1.2); }
                .btn-edit {
                    background-color: #2a3a2a;
                    color: #aaffaa;
                    border: 1px solid #3a5a3a;
                    border-radius: 10px;
                    padding: 0.4rem 0.9rem;
                    font-size: 0.82rem;
                    font-weight: 500;
                    cursor: pointer;
                    text-decoration: none;
                    transition: background 0.2s;
                }
                .btn-edit:hover { background-color: #3a5a3a; }
                .btn-delete {
                    background-color: #2a1a1a;
                    color: #ff6b6b;
                    border: 1px solid #5a2a2a;
                    border-radius: 10px;
                    padding: 0.4rem 0.9rem;
                    font-size: 0.82rem;
                    font-weight: 500;
                    cursor: pointer;
                    transition: background 0.2s;
                }
                .btn-delete:hover { background-color: #5a1a1a; }

                /* ---- FORMULAIRES ---- */
                .form-card {
                    background-color: #1a2e1a;
                    border: 1px solid #2a4a2a;
                    border-radius: 16px;
                    padding: 2rem;
                }
                .form-group {
                    margin-bottom: 1.1rem;
                }
                .form-group label {
                    display: block;
                    font-size: 0.8rem;
                    font-weight: 600;
                    color: #888888;
                    text-transform: uppercase;
                    letter-spacing: 0.06em;
                    margin-bottom: 0.4rem;
                }
                .form-group input, .form-group textarea {
                    width: 100%;
                    background-color: #111a11;
                    border: 1px solid #2a4a2a;
                    color: #ffffff;
                    border-radius: 10px;
                    padding: 0.75rem 1rem;
                    font-size: 0.95rem;
                    outline: none;
                    transition: border-color 0.2s;
                }
                .form-group input:focus {
                    border-color: #4a8a4a;
                }
                .form-group input::placeholder {
                    color: #555555;
                }
                .btn-submit {
                    width: 100%;
                    background-color: #2d5a2d;
                    color: #ffffff;
                    border: none;
                    border-radius: 12px;
                    padding: 0.9rem;
                    font-size: 1rem;
                    font-weight: 600;
                    cursor: pointer;
                    margin-top: 0.5rem;
                    transition: background 0.2s;
                }
                .btn-submit:hover { background-color: #3a7a3a; }
                .btn-back {
                    display: inline-block;
                    margin-top: 1rem;
                    color: #888888;
                    text-decoration: none;
                    font-size: 0.85rem;
                }
                .btn-back:hover { color: #ffffff; }

                /* ---- EMPTY STATE ---- */
                .empty-state {
                    text-align: center;
                    padding: 4rem 2rem;
                    color: #555555;
                }
                .empty-state p { margin-bottom: 1.5rem; font-size: 0.95rem; }

                /* ---- DISCLAIMER ---- */
                .disclaimer {
                    font-size: 0.75rem;
                    color: #555555;
                    text-align: center;
                    margin-top: 1.5rem;
                }

                /* ---- SECTION TITRE ---- */
                .section-label {
                    font-size: 0.75rem;
                    font-weight: 600;
                    color: #555555;
                    text-transform: uppercase;
                    letter-spacing: 0.08em;
                    margin-bottom: 0.8rem;
                    margin-top: 1.5rem;
                }
            </style>
        </head>
        <body>

            <!-- NAVBAR -->
            <nav class="navbar">
                <a href="/cars" class="navbar-brand">🚗 Classic Cars</a>
                <div class="navbar-links">
                    <a href="/cars" class="nav-link \(activePage == "cars" ? "active" : "")">
                        Toutes les voitures
                    </a>
                    <a href="/cars/favorites" class="nav-link \(activePage == "favorites" ? "active" : "")">
                        ⭐ Favoris
                    </a>
                    <a href="/cars/new" class="nav-link \(activePage == "new" ? "active" : "")">
                        + Ajouter
                    </a>
                </div>
            </nav>

            <main class="container">
                \(body)
            </main>

        </body>
        </html>
        """
    }

    // -------------------------------------------------------
    // PAGE PRINCIPALE - liste de toutes les voitures
    // -------------------------------------------------------
    static func renderIndex(cars: [Car]) -> HTML {
        let cards = cars.map { car in
            let star      = car.isFavorite ? "⭐" : "☆"
            let cardClass = car.isFavorite ? "car-card is-favorite" : "car-card"
            return """
            <div class="\(cardClass)">
                <div class="car-info">
                    <h3>\(car.make) \(car.model)</h3>
                    <p>\(car.year) &nbsp;·&nbsp; \(car.color) &nbsp;·&nbsp; \(car.mileage) km</p>
                </div>
                <div class="car-actions">
                    <form method="POST" action="/cars/\(car.id!)/favorite" style="display:inline">
                        <button type="submit" class="btn-star">\(star)</button>
                    </form>
                    <a href="/cars/\(car.id!)/edit" class="btn-edit">Modifier</a>
                    <form method="POST" action="/cars/\(car.id!)/delete"
                          onsubmit="return confirm('Supprimer \(car.make) \(car.model) ?')"
                          style="display:inline">
                        <button type="submit" class="btn-delete">Supprimer</button>
                    </form>
                </div>
            </div>
            """
        }.joined()

        let content = cars.isEmpty ? """
            <div class="empty-state">
                <p>Aucune voiture enregistrée pour l'instant.</p>
                <a href="/cars/new" class="add-btn">+ Ajouter la première</a>
            </div>
            """ : """
            <p class="section-label">\(cars.count) voiture\(cars.count > 1 ? "s" : "")</p>
            \(cards)
            """

        let body = """
        <div class="page-header">
            <h1>Mes voitures</h1>
            <p>Gérez votre collection de voitures classiques</p>
        </div>
        <a href="/cars/new" class="add-btn">+ Ajouter une voiture</a>
        \(content)
        <p class="disclaimer">*cliquez sur ☆ pour ajouter aux favoris</p>
        """

        return HTML(value: layout(title: "Classic Cars", body: body, activePage: "cars"))
    }

    // -------------------------------------------------------
    // PAGE FAVORIS - voitures likées
    // -------------------------------------------------------
    static func renderFavorites(cars: [Car]) -> HTML {
        let favorites = cars.filter { $0.isFavorite }

        let cards = favorites.map { car in
            """
            <div class="car-card is-favorite">
                <div class="car-info">
                    <h3>⭐ \(car.make) \(car.model)</h3>
                    <p>\(car.year) &nbsp;·&nbsp; \(car.color) &nbsp;·&nbsp; \(car.mileage) km</p>
                </div>
                <div class="car-actions">
                    <form method="POST" action="/cars/\(car.id!)/favorite" style="display:inline">
                        <button type="submit" class="btn-star">★</button>
                    </form>
                    <a href="/cars/\(car.id!)/edit" class="btn-edit">Modifier</a>
                </div>
            </div>
            """
        }.joined()

        let content = favorites.isEmpty ? """
            <div class="empty-state">
                <p>Aucune voiture en favori pour l'instant.</p>
                <a href="/cars" class="add-btn">Voir toutes les voitures</a>
            </div>
            """ : """
            <p class="section-label">\(favorites.count) favori\(favorites.count > 1 ? "s" : "")</p>
            \(cards)
            """

        let body = """
        <div class="page-header">
            <h1>⭐ Favoris</h1>
            <p>Vos voitures classiques préférées</p>
        </div>
        \(content)
        """

        return HTML(value: layout(title: "Favoris — Classic Cars", body: body, activePage: "favorites"))
    }

    // -------------------------------------------------------
    // FORMULAIRE AJOUT - nouvelle voiture
    // -------------------------------------------------------
    static func renderNewForm(error: String? = nil) -> HTML {
        let errorMsg = error.map {
            "<p style='color:#ff6b6b;margin-bottom:1rem;font-size:0.9rem;'>\($0)</p>"
        } ?? ""

        let body = """
        <div class="page-header">
            <h1>Ajouter</h1>
            <p>Nouvelle voiture classique</p>
        </div>
        \(errorMsg)
        <div class="form-card">
            <form method="POST" action="/cars">
                <div class="form-group">
                    <label>Marque</label>
                    <input type="text" name="make" placeholder="Mercedes, BMW, Citroën…" required>
                </div>
                <div class="form-group">
                    <label>Modèle</label>
                    <input type="text" name="model" placeholder="W123, 2002, DS…" required>
                </div>
                <div class="form-group">
                    <label>Année</label>
                    <input type="number" name="year" placeholder="1982" min="1886" max="2025" required>
                </div>
                <div class="form-group">
                    <label>Couleur</label>
                    <input type="text" name="color" placeholder="Blanc, Vert anglais…">
                </div>
                <div class="form-group">
                    <label>Kilométrage</label>
                    <input type="number" name="mileage" placeholder="120000" min="0">
                </div>
                <button type="submit" class="btn-submit">Enregistrer</button>
            </form>
        </div>
        <a href="/cars" class="btn-back">← Retour à la liste</a>
        <p class="disclaimer">*make sure to click the button for results</p>
        """

        return HTML(value: layout(title: "Ajouter — Classic Cars", body: body, activePage: "new"))
    }

    // -------------------------------------------------------
    // FORMULAIRE EDITION - modifier une voiture existante
    // -------------------------------------------------------
    static func renderEditForm(car: Car, error: String? = nil) -> HTML {
        let errorMsg = error.map {
            "<p style='color:#ff6b6b;margin-bottom:1rem;font-size:0.9rem;'>\($0)</p>"
        } ?? ""

        let body = """
        <div class="page-header">
            <h1>Modifier</h1>
            <p>\(car.make) \(car.model) · \(car.year)</p>
        </div>
        \(errorMsg)
        <div class="form-card">
            <form method="POST" action="/cars/\(car.id!)/update">
                <div class="form-group">
                    <label>Marque</label>
                    <input type="text" name="make" value="\(car.make)" required>
                </div>
                <div class="form-group">
                    <label>Modèle</label>
                    <input type="text" name="model" value="\(car.model)" required>
                </div>
                <div class="form-group">
                    <label>Année</label>
                    <input type="number" name="year" value="\(car.year)" min="1886" max="2025" required>
                </div>
                <div class="form-group">
                    <label>Couleur</label>
                    <input type="text" name="color" value="\(car.color)">
                </div>
                <div class="form-group">
                    <label>Kilométrage</label>
                    <input type="number" name="mileage" value="\(car.mileage)" min="0">
                </div>
                <button type="submit" class="btn-submit">Mettre à jour</button>
            </form>
        </div>
        <a href="/cars" class="btn-back">← Retour à la liste</a>
        <p class="disclaimer">*make sure to click the button for results</p>
        """

        return HTML(value: layout(title: "Modifier — Classic Cars", body: body, activePage: "cars"))
    }
}