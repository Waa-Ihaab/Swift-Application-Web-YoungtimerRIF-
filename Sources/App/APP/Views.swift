// Views.swift
// Kari Ihab

import Foundation

/// Page HTML de base
func basePage(title: String, content: String, error: String? = nil) -> String {
  let errorBanner =
    error.map { msg in
      """
      <div class="error-banner">
        <span>⚠ \(msg)</span>
        <a href="/">← Retour</a>
      </div>
      """
    } ?? ""

  return """
    <!DOCTYPE html>
    <html lang="fr">
    <head>
      <meta charset="UTF-8"/>
      <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
      <title>\(title) - YoungtimerRIF</title>
      <link rel="preconnect" href="https://fonts.googleapis.com"/>
      <link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@400;600;700;900&family=Barlow:wght@400;500;600&display=swap" rel="stylesheet"/>
      <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
          --black:   #0a0a0a;
          --dark:    #111111;
          --card:    #181818;
          --border:  #2a2a2a;
          --red:     #e8001d;
          --red-h:   #ff1a33;
          --white:   #ffffff;
          --gray:    #999999;
          --lgray:   #cccccc;
          --font-h:  'Barlow Condensed', sans-serif;
          --font-b:  'Barlow', sans-serif;
        }

        body {
          background: var(--black);
          color: var(--white);
          font-family: var(--font-b);
          font-size: 15px;
          line-height: 1.5;
          min-height: 100vh;
        }

        /* NAVBAR */
        nav {
          background: var(--dark);
          border-bottom: 2px solid var(--red);
          padding: 0 40px;
          display: flex;
          align-items: center;
          justify-content: space-between;
          height: 64px;
          position: sticky;
          top: 0;
          z-index: 100;
        }
        .logo {
          font-family: var(--font-h);
          font-size: 26px;
          font-weight: 900;
          letter-spacing: -0.5px;
          color: var(--white);
          text-decoration: none;
        }
        .logo span { color: var(--red); }
        nav ul {
          list-style: none;
          display: flex;
          gap: 32px;
          align-items: center;
        }
        nav a {
          color: var(--lgray);
          text-decoration: none;
          font-size: 13px;
          font-weight: 600;
          letter-spacing: 1px;
          text-transform: uppercase;
          transition: color .2s;
        }
        nav a:hover { color: var(--red); }
        .btn-add {
          background: var(--red) !important;
          color: var(--white) !important;
          padding: 8px 18px;
          border-radius: 2px;
          font-size: 12px !important;
          letter-spacing: 1.5px !important;
        }
        .btn-add:hover { background: var(--red-h) !important; }

        /* MAIN */
        main { max-width: 1280px; margin: 0 auto; padding: 40px 32px 80px; }

        /* BANNIERE D'ERREUR */
        .error-banner {
          background: #2a0008;
          border: 1px solid var(--red);
          color: #ff8090;
          padding: 12px 20px;
          margin-bottom: 28px;
          display: flex;
          justify-content: space-between;
          align-items: center;
          font-size: 14px;
          border-radius: 2px;
        }
        .error-banner a { color: var(--lgray); font-size: 13px; }

        /* EN-TETE */
        .page-header {
          margin-bottom: 36px;
          border-bottom: 1px solid var(--border);
          padding-bottom: 24px;
        }
        .page-header h1 {
          font-family: var(--font-h);
          font-size: 42px;
          font-weight: 900;
          letter-spacing: -0.5px;
          text-transform: uppercase;
          line-height: 1;
        }
        .page-header p { color: var(--gray); margin-top: 6px; font-size: 14px; }

        /* RECHERCHE */
        .search-bar {
          display: flex;
          gap: 10px;
          margin-bottom: 36px;
        }
        .search-bar input {
          flex: 1;
          background: var(--card);
          border: 1px solid var(--border);
          color: var(--white);
          padding: 12px 16px;
          font-family: var(--font-b);
          font-size: 14px;
          outline: none;
          transition: border-color .2s;
          border-radius: 2px;
        }
        .search-bar input::placeholder { color: var(--gray); }
        .search-bar input:focus { border-color: var(--red); }
        .search-bar button {
          background: var(--red);
          color: var(--white);
          border: none;
          padding: 12px 24px;
          font-family: var(--font-h);
          font-size: 14px;
          font-weight: 700;
          letter-spacing: 1px;
          text-transform: uppercase;
          cursor: pointer;
          border-radius: 2px;
          transition: background .2s;
        }
        .search-bar button:hover { background: var(--red-h); }

        /* TRI */
        .sort-bar {
          display: flex;
          gap: 8px;
          margin-bottom: 28px;
          align-items: center;
        }
        .sort-bar span {
          color: var(--gray);
          font-size: 12px;
          letter-spacing: 1px;
          text-transform: uppercase;
          margin-right: 4px;
        }
        .sort-btn {
          background: var(--card);
          border: 1px solid var(--border);
          color: var(--lgray);
          padding: 6px 14px;
          font-size: 12px;
          font-weight: 600;
          letter-spacing: 0.5px;
          cursor: pointer;
          border-radius: 2px;
          text-decoration: none;
          transition: all .2s;
        }
        .sort-btn:hover, .sort-btn.active {
          border-color: var(--red);
          color: var(--red);
        }

        /* NOMBRE DE RESULTATS */
        .results-count {
          font-family: var(--font-h);
          font-size: 22px;
          font-weight: 700;
          margin-bottom: 20px;
          color: var(--white);
        }
        .results-count span { color: var(--red); }

        /* GRILLE DES VOITURES */
        .cars-grid {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
          gap: 2px;
        }

        /* CARD */
        .car-card {
          background: var(--card);
          border: 1px solid var(--border);
          transition: border-color .25s, transform .2s;
          position: relative;
          overflow: hidden;
        }
        .car-card:hover {
          border-color: var(--red);
          transform: translateY(-2px);
        }
        .car-card-img {
          width: 100%;
          height: 180px;
          background: linear-gradient(135deg, #1c1c1c 0%, #222 50%, #1a1a1a 100%);
          display: flex;
          align-items: center;
          justify-content: center;
          border-bottom: 1px solid var(--border);
          position: relative;
          overflow: hidden;
        }
        .car-card-img svg {
          opacity: 0.12;
          width: 180px;
        }
        .car-year-badge {
          position: absolute;
          top: 12px;
          left: 12px;
          background: var(--red);
          color: var(--white);
          font-family: var(--font-h);
          font-size: 13px;
          font-weight: 700;
          letter-spacing: 1px;
          padding: 3px 10px;
          border-radius: 1px;
        }
        .car-condition-badge {
          position: absolute;
          top: 12px;
          right: 12px;
          font-size: 11px;
          font-weight: 600;
          letter-spacing: 0.5px;
          padding: 3px 10px;
          border-radius: 1px;
          text-transform: uppercase;
        }
        .badge-excellent { background: #0d2e1a; color: #4ade80; border: 1px solid #166534; }
        .badge-bon       { background: #2e2200; color: #fbbf24; border: 1px solid #92400e; }
        .badge-restaurer { background: #2e0a0a; color: #f87171; border: 1px solid #991b1b; }

        .car-card-body { padding: 18px 20px 14px; }
        .car-ref {
          font-size: 10px;
          color: var(--gray);
          letter-spacing: 1.5px;
          text-transform: uppercase;
          margin-bottom: 4px;
        }
        .car-title {
          font-family: var(--font-h);
          font-size: 34px;
          font-weight: 900;
          line-height: 1;
          margin-bottom: 6px;
          text-transform: uppercase;
          letter-spacing: -0.5px;
        }
        .car-model {
          font-size: 13px;
          color: var(--gray);
          margin-bottom: 14px;
        }
        .car-specs {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 8px;
          margin-bottom: 16px;
          padding-top: 14px;
          border-top: 1px solid var(--border);
        }
        .spec-item { display: flex; flex-direction: column; gap: 1px; }
        .spec-label {
          font-size: 10px;
          color: var(--gray);
          letter-spacing: 1px;
          text-transform: uppercase;
        }
        .spec-value { font-size: 14px; font-weight: 500; color: var(--lgray); }
        .car-price {
          font-family: var(--font-h);
          font-size: 28px;
          font-weight: 900;
          color: var(--white);
          margin-bottom: 16px;
          letter-spacing: -0.5px;
        }
        .car-price small {
          font-size: 12px;
          color: var(--gray);
          font-weight: 400;
          letter-spacing: 0;
          font-family: var(--font-b);
        }
        .card-actions {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 1px;
          margin: 0 -20px -14px;
          border-top: 1px solid var(--border);
        }
        .card-actions a, .card-actions button {
          display: block;
          padding: 11px;
          text-align: center;
          font-family: var(--font-h);
          font-size: 12px;
          font-weight: 700;
          letter-spacing: 1.5px;
          text-transform: uppercase;
          cursor: pointer;
          border: none;
          transition: background .2s, color .2s;
          text-decoration: none;
        }
        .btn-detail {
          background: var(--dark);
          color: var(--lgray);
        }
        .btn-detail:hover { background: #222; color: var(--white); }
        .btn-offer {
          background: var(--red);
          color: var(--white);
          width: 100%;
        }
        .btn-offer:hover { background: var(--red-h); }

        /* ETAT VIDE */
        .empty-state {
          text-align: center;
          padding: 80px 20px;
          color: var(--gray);
        }
        .empty-state h2 {
          font-family: var(--font-h);
          font-size: 32px;
          font-weight: 700;
          color: var(--lgray);
          margin-bottom: 12px;
          text-transform: uppercase;
        }

        /* PAGE DETAIL */
        .detail-back {
          display: inline-flex;
          align-items: center;
          gap: 8px;
          color: var(--gray);
          text-decoration: none;
          font-size: 13px;
          font-weight: 600;
          letter-spacing: 0.5px;
          text-transform: uppercase;
          margin-bottom: 28px;
          transition: color .2s;
        }
        .detail-back:hover { color: var(--red); }
        .detail-layout {
          display: block;
          max-width: 600px;
          margin: 0 auto;
        }
        .detail-img {
          background: #181818;
          height: 360px;
          display: flex;
          align-items: center;
          justify-content: center;
          border: 1px solid var(--border);
          position: relative;
        }
        .detail-img svg { opacity: 0.08; width: 260px; }
        .detail-info {
          background: var(--card);
          border: 1px solid var(--border);
          padding: 28px;
        }
        .detail-ref {
          font-size: 11px;
          color: var(--gray);
          letter-spacing: 2px;
          text-transform: uppercase;
          margin-bottom: 6px;
        }
        .detail-title {
          font-family: var(--font-h);
          font-size: 36px;
          font-weight: 900;
          line-height: 1;
          text-transform: uppercase;
          margin-bottom: 4px;
        }
        .detail-subtitle { color: var(--gray); font-size: 15px; margin-bottom: 24px; }
        .detail-price {
          font-family: var(--font-h);
          font-size: 40px;
          font-weight: 900;
          color: var(--white);
          border-top: 1px solid var(--border);
          border-bottom: 1px solid var(--border);
          padding: 16px 0;
          margin-bottom: 24px;
          letter-spacing: -1px;
        }
        .detail-specs {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 16px;
          margin-bottom: 28px;
        }
        .detail-spec { display: flex; flex-direction: column; gap: 3px; }
        .detail-spec-label {
          font-size: 10px;
          letter-spacing: 1.5px;
          text-transform: uppercase;
          color: var(--gray);
        }
        .detail-spec-value { font-size: 16px; font-weight: 500; }
        .detail-actions { display: flex; flex-direction: column; gap: 8px; }
        .btn-primary {
          background: var(--red);
          color: var(--white);
          border: none;
          padding: 14px;
          font-family: var(--font-h);
          font-size: 14px;
          font-weight: 700;
          letter-spacing: 1.5px;
          text-transform: uppercase;
          cursor: pointer;
          width: 100%;
          transition: background .2s;
          text-align: center;
          text-decoration: none;
          display: block;
          border-radius: 1px;
        }
        .btn-primary:hover { background: var(--red-h); }
        .btn-secondary {
          background: transparent;
          color: var(--lgray);
          border: 1px solid var(--border);
          padding: 13px;
          font-family: var(--font-h);
          font-size: 14px;
          font-weight: 700;
          letter-spacing: 1.5px;
          text-transform: uppercase;
          cursor: pointer;
          width: 100%;
          transition: all .2s;
          text-align: center;
          text-decoration: none;
          display: block;
          border-radius: 1px;
        }
        .btn-secondary:hover { border-color: var(--red); color: var(--red); }
        .btn-danger {
          background: transparent;
          color: #f87171;
          border: 1px solid #991b1b;
          padding: 13px;
          font-family: var(--font-h);
          font-size: 14px;
          font-weight: 700;
          letter-spacing: 1.5px;
          text-transform: uppercase;
          cursor: pointer;
          width: 100%;
          transition: all .2s;
          border-radius: 1px;
        }
        .btn-danger:hover { background: #2e0a0a; }

        /* FORMULAIRE */
        .form-container {
          max-width: 680px;
        }
        .form-grid {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 20px;
          margin-bottom: 20px;
        }
        .form-group { display: flex; flex-direction: column; gap: 6px; }
        .form-group.full { grid-column: 1 / -1; }
        label {
          font-size: 11px;
          font-weight: 600;
          letter-spacing: 1.5px;
          text-transform: uppercase;
          color: var(--gray);
        }
        input[type=text], input[type=number], select {
          background: var(--card);
          border: 1px solid var(--border);
          color: var(--white);
          padding: 12px 14px;
          font-family: var(--font-b);
          font-size: 14px;
          outline: none;
          transition: border-color .2s;
          width: 100%;
          border-radius: 2px;
          appearance: none;
          -webkit-appearance: none;
        }
        input:focus, select:focus { border-color: var(--red); }
        select option { background: var(--card); }
        .form-actions {
          display: flex;
          gap: 12px;
          margin-top: 32px;
          padding-top: 24px;
          border-top: 1px solid var(--border);
        }

        /* FOOTER */
        footer {
          border-top: 1px solid var(--border);
          padding: 28px 40px;
          display: flex;
          justify-content: center;
          align-items: center;
          color: var(--gray);
          font-size: 12px;
          letter-spacing: 0.5px;
          margin-top: 60px;
          text-align: center;
        }
        footer strong { color: var(--red); }

        @media (max-width: 768px) {
          nav { padding: 0 20px; }
          main { padding: 24px 16px 60px; }
          .detail-layout { grid-template-columns: 1fr; }
          .form-grid { grid-template-columns: 1fr; }
          .cars-grid { grid-template-columns: 1fr; }
        }
      </style>
    </head>
    <body>
      <nav>
        <a class="logo" href="/">Youngtimer<span>RIF</span></a>
        <ul>
          <li><a href="/">Catalogue</a></li>
          <li><a href="/add" class="btn-add">+ Ajouter</a></li>
        </ul>
      </nav>
      <main>
        \(errorBanner)
        \(content)
      </main>
      <footer>
        <span>© 2026 <strong>Kari Ihab</strong> - Université Paris 8</span>
      </footer>
    </body>
    </html>
    """
}

/// Retourne la classe CSS selon l'état
func conditionClass(_ condition: String) -> String {
  switch condition {
  case "Excellent": return "badge-excellent"
  case "Bon": return "badge-bon"
  default: return "badge-restaurer"
  }
}

/// Page principale
func indexPage(cars: [Car], searchQuery: String = "", sortBy: String = "") -> String {
  let header = """
    <div class="page-header">
      <h1>Acheter des Youngtimers</h1>
      <p>Voitures des années 1970–2010 · Collection &amp; Usage</p>
    </div>
    """

  // Barre de recherche
  let searchBar = """
    <form class="search-bar" method="get" action="/search">
      <input type="text" name="q" placeholder="Marque, modèle, couleur…"
             value="\(searchQuery)"/>
      <button type="submit">Rechercher</button>
    </form>
    """

  // Boutons de tri
  let sorts = [("brand", "Marque"), ("year", "Année"), ("price", "Prix"), ("mileage", "Km")]
  let sortLinks = sorts.map { (key, label) in
    let active = sortBy == key ? "active" : ""
    return "<a href=\"/?sort=\(key)\" class=\"sort-btn \(active)\">\(label)</a>"
  }.joined()
  let sortBar = """
    <div class="sort-bar">
      <span>Trier par :</span>
      \(sortLinks)
      \(sortBy.isEmpty ? "" : "<a href=\"/\" class=\"sort-btn\">✕ Réinitialiser</a>")
    </div>
    """

  // Nombre d'annonces
  let count = """
    <p class="results-count">
      <span>\(cars.count)</span> annonce\(cars.count > 1 ? "s" : "")
      \(searchQuery.isEmpty ? "" : "pour « \(searchQuery) »")
    </p>
    """

  // Liste des cards
  let grid: String
  if cars.isEmpty {
    grid = """
      <div class="empty-state">
        <h2>Aucun résultat</h2>
        <p>Essayez une autre recherche ou <a href="/add" style="color:var(--red)">ajoutez une voiture</a>.</p>
      </div>
      """
  } else {
    let cards = cars.map { carCard($0) }.joined(separator: "\n")
    grid = "<div class=\"cars-grid\">\n\(cards)\n</div>"
  }

  return basePage(
    title: "Catalogue",
    content: header + searchBar + sortBar + count + grid
  )
}

/// Card d'une voiture
func carCard(_ car: Car) -> String {
  let id = car.id ?? 0
  let condClass = conditionClass(car.condition)
  let condLabel = car.condition == "À restaurer" ? "À restaurer" : car.condition

  return """
    <div class="car-card">
      <div class="car-card-body">
        <div style="display:flex; justify-content:space-between; align-items:flex-start; gap:12px; margin-bottom:10px;">
          <span class="car-year-badge" style="position:static;">\(car.year)</span>
          <span class="car-condition-badge \(condClass)" style="position:static;">\(condLabel)</span>
        </div>

        <p class="car-ref">Réf. #\(String(format: "%06d", id))</p>
        <h2 class="car-title">\(car.brand)</h2>
        <p class="car-model">\(car.model) · \(car.color)</p>

        <div class="car-specs">
          <div class="spec-item">
            <span class="spec-label">Kilométrage</span>
            <span class="spec-value">\(car.formattedMileage)</span>
          </div>
          <div class="spec-item">
            <span class="spec-label">Année</span>
            <span class="spec-value">\(car.year)</span>
          </div>
          <div class="spec-item">
            <span class="spec-label">Couleur</span>
            <span class="spec-value">\(car.color)</span>
          </div>
          <div class="spec-item">
            <span class="spec-label">État</span>
            <span class="spec-value">\(car.condition)</span>
          </div>
        </div>

        <div class="car-price">\(car.formattedPrice)</div>

        <div class="card-actions">
          <a href="/cars/\(id)" class="btn-detail">Détails</a>
          <a href="/edit/\(id)" class="btn-offer">Modifier →</a>
        </div>
      </div>
    </div>
    """
}

/// Page détail d'une voiture
func detailPage(car: Car) -> String {
  let id = car.id ?? 0
  let condClass = conditionClass(car.condition)

  let content = """
    <a href="/" class="detail-back">← Retour au catalogue</a>
    <div class="detail-layout">
      <div class="detail-info">
        <div style="display:flex; justify-content:space-between; margin-bottom:12px;">
          <span class="car-year-badge" style="position:static;">\(car.year)</span>
          <span class="car-condition-badge \(condClass)" style="position:static;">\(car.condition)</span>
        </div>
        <p class="detail-ref">Réf. #\(String(format: "%06d", id))</p>        
        <h1 class="detail-title">\(car.brand)</h1>
        <p class="detail-subtitle">\(car.model)</p>
        <div class="detail-price">\(car.formattedPrice)</div>
        <div class="detail-specs">
          <div class="detail-spec">
            <span class="detail-spec-label">Kilométrage</span>
            <span class="detail-spec-value">\(car.formattedMileage)</span>
          </div>
          <div class="detail-spec">
            <span class="detail-spec-label">Année</span>
            <span class="detail-spec-value">\(car.year)</span>
          </div>
          <div class="detail-spec">
            <span class="detail-spec-label">Couleur</span>
            <span class="detail-spec-value">\(car.color)</span>
          </div>
          <div class="detail-spec">
            <span class="detail-spec-label">État</span>
            <span class="detail-spec-value">\(car.condition)</span>
          </div>
        </div>
        <div class="detail-actions">
          <a href="/edit/\(id)" class="btn-primary">Modifier cette annonce</a>
          <a href="/" class="btn-secondary">Retour au catalogue</a>
          <form method="post" action="/delete/\(id)"
                onsubmit="return confirm('Supprimer cette voiture ?')">
            <button type="submit" class="btn-danger">Supprimer l'annonce</button>
          </form>
        </div>
      </div>
    </div>
    """

  return basePage(title: "\(car.brand) \(car.model)", content: content)
}

/// Page formulaire ajout / modification
func formPage(car: Car? = nil, error: String? = nil) -> String {
  let isEdit = car != nil
  let id = car?.id ?? 0
  let action = isEdit ? "/update/\(id)" : "/create"
  let pageTitle = isEdit ? "Modifier l'annonce" : "Ajouter une voiture"

  func val(_ v: String) -> String { v }
  func sel(_ current: String, _ option: String) -> String {
    current == option ? "selected" : ""
  }

  let conditions = ["Excellent", "Bon", "À restaurer"]
  let conditionOptions = conditions.map { c in
    "<option value=\"\(c)\" \(sel(car?.condition ?? "", c))>\(c)</option>"
  }.joined()

  let content = """
    <div class="page-header">
      <h1>\(pageTitle)</h1>
      <p>\(isEdit ? "Modifiez les informations de cette annonce." : "Renseignez les informations de la voiture à ajouter au catalogue.")</p>
    </div>
    <form class="form-container" method="post" action="\(action)">
      <div class="form-grid">
        <div class="form-group">
          <label for="brand">Marque *</label>
          <input type="text" id="brand" name="brand"
                 value="\(car?.brand ?? "")"
                 placeholder="ex: Mercedes-Benz" required/>
        </div>
        <div class="form-group">
          <label for="model">Modèle *</label>
          <input type="text" id="model" name="model"
                 value="\(car?.model ?? "")"
                 placeholder="ex: W124 200E" required/>
        </div>
        <div class="form-group">
          <label for="year">Année *</label>
          <input type="number" id="year" name="year"
                 value="\(car.map { String($0.year) } ?? "")"
                 placeholder="ex: 1989" min="1970" max="2010" required/>
        </div>
        <div class="form-group">
          <label for="mileage">Kilométrage (km) *</label>
          <input type="number" id="mileage" name="mileage"
                 value="\(car.map { String($0.mileage) } ?? "")"
                 placeholder="ex: 145000" min="0" required/>
        </div>
        <div class="form-group">
          <label for="price">Prix (€) *</label>
          <input type="number" id="price" name="price"
                 value="\(car.map { String(Int($0.price)) } ?? "")"
                 placeholder="ex: 8500" min="0" required/>
        </div>
        <div class="form-group">
          <label for="color">Couleur *</label>
          <input type="text" id="color" name="color"
                 value="\(car?.color ?? "")"
                 placeholder="ex: Gris Métallisé" required/>
        </div>
        <div class="form-group full">
          <label for="condition">État *</label>
          <select id="condition" name="condition" required>
            <option value="">- Sélectionner -</option>
            \(conditionOptions)
          </select>
        </div>
      </div>
      <div class="form-actions">
        <button type="submit" class="btn-primary" style="max-width:240px">
          \(isEdit ? "Enregistrer les modifications" : "Ajouter au catalogue")
        </button>
        <a href="\(isEdit ? "/cars/\(id)" : "/")" class="btn-secondary" style="max-width:160px">
          Annuler
        </a>
      </div>
    </form>
    """

  return basePage(title: pageTitle, content: content, error: error)
}

/// Page de recherche
func searchPage(cars: [Car], query: String) -> String {
  let header = """
    <div class="page-header">
      <h1>Résultats de recherche</h1>
      <p>Résultats pour : <strong style="color:var(--white)">\(query)</strong></p>
    </div>
    """
  return basePage(
    title: "Recherche : \(query)",
    content: header + indexBody(cars: cars, searchQuery: query, sortBy: "")
  )
}

/// Contenu de la liste des voitures
private func indexBody(cars: [Car], searchQuery: String, sortBy: String) -> String {
  let count = """
    <p class="results-count">
      <span>\(cars.count)</span> voiture\(cars.count > 1 ? "s" : "") trouvée\(cars.count > 1 ? "s" : "")
    </p>
    """
  if cars.isEmpty {
    return count + """
      <div class="empty-state">
        <h2>Aucun résultat</h2>
        <p>Essayez une autre recherche ou <a href="/add" style="color:var(--red)">ajoutez une voiture</a>.</p>
      </div>
      """
  }
  let cards = cars.map { carCard($0) }.joined(separator: "\n")
  return count + "<div class=\"cars-grid\">\n\(cards)\n</div>"
}
