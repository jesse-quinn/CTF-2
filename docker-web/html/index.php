<?php
// Minimal page router. The templates live next to this file and are pulled in by
// the "page" query parameter so navigation stays a single entry point.
$page = $_GET['page'] ?? 'home.php';

include($page);
