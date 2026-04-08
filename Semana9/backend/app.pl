#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use Mojolicious::Lite -signatures;

hook before_dispatch => sub ($c) {
  $c->res->headers->header('Access-Control-Allow-Origin' => '*');
  $c->res->headers->header('Access-Control-Allow-Methods' => 'GET, OPTIONS');
  $c->res->headers->header('Access-Control-Allow-Headers' => 'Content-Type');
};

options '/saludo' => sub ($c) {
  $c->render(text => '', status => 204);
};

get '/saludo' => sub ($c) {
  $c->render(json => { mensaje => 'Respuesta desde el puerto 3001' });
};

app->start;
