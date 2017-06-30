# coding: utf-8
require 'slack-ruby-client'
require 'rubygems'
require 'dbi'

dbh = DBI.connect('DBI:SQLite3:kakinSlot.db')
dbh.do("CREATE TABLE person (
        name CHAR(20) PRIMARY KEY,
        coin INT NOT NULL,
        kakin INT NOT NULL        
        )")
dbh.disconnect