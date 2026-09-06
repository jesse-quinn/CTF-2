<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nimbus Notes</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap" rel="stylesheet">
    <style>
        :root { color-scheme: dark; }
        body {
            background: radial-gradient(circle at top, #1b2735 0%, #090a0f 100%);
            color: #e7ecf3;
            font-family: 'Inter', system-ui, sans-serif;
            margin: 0;
            min-height: 100vh;
        }
        header {
            padding: 28px 48px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-bottom: 1px solid rgba(255, 255, 255, 0.08);
        }
        header .brand { font-weight: 800; font-size: 22px; letter-spacing: 0.5px; }
        nav a {
            color: #9fb3c8;
            text-decoration: none;
            margin-left: 24px;
            font-weight: 600;
        }
        nav a:hover { color: #ffffff; }
        main { max-width: 720px; margin: 0 auto; padding: 72px 24px; }
        h1 { font-size: 40px; margin-bottom: 12px; }
        p.lead { color: #9fb3c8; font-size: 18px; line-height: 1.6; }
        .card {
            margin-top: 40px;
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 14px;
            padding: 28px;
        }
        code { background: rgba(255, 255, 255, 0.08); padding: 2px 6px; border-radius: 6px; }
        footer { text-align: center; color: #5b6b7d; padding: 40px 0; }
    </style>
</head>
<body>
    <header>
        <div class="brand">Nimbus Notes</div>
        <nav>
            <a href="index.php?page=home.php">Home</a>
            <a href="index.php?page=about.php">About</a>
        </nav>
    </header>
    <main>
        <h1>Your notes, everywhere.</h1>
        <p class="lead">
            Nimbus Notes keeps your ideas synced across every device. This is an
            early internal preview; only the marketing pages are wired up so far.
        </p>
        <div class="card">
            <p>Pages are loaded through the router, for example
            <code>index.php?page=about.php</code>. More sections are on the way.</p>
        </div>
    </main>
    <footer>Nimbus Notes internal preview</footer>
</body>
</html>
