<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>About - Nimbus Notes</title>
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
        nav a { color: #9fb3c8; text-decoration: none; margin-left: 24px; font-weight: 600; }
        nav a:hover { color: #ffffff; }
        main { max-width: 720px; margin: 0 auto; padding: 72px 24px; }
        h1 { font-size: 36px; margin-bottom: 12px; }
        p { color: #cdd8e4; font-size: 17px; line-height: 1.7; }
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
        <h1>About</h1>
        <p>
            Nimbus Notes is built by a very small team. Milo runs the platform and
            handles deployments to our production host; the rest of us just write
            features. If a page will not load, ping Milo.
        </p>
    </main>
</body>
</html>
