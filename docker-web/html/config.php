<?php
// Central application configuration. Not linked from any page; the router pulls
// it in where a database connection is needed. Kept out of version control on
// the real host, but it lingers in the webroot on this preview box.
//
// Milo set the database account to match his own system login so he would not
// have to remember two passwords. It was meant to be temporary.

$DB_HOST = '127.0.0.1';
$DB_NAME = 'nimbus';
$DB_USER = 'milo';
$DB_PASS = '8EPYJySLj0JkertR';

// TODO(milo): move these into a real secrets store before we ship.
