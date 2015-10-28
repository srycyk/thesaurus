
# A Thesaurus

See: http://thesaurus-lexdump.rhcloud.com/

This is a two-page web application that shows links between words.
It is briefly described in the partial,
**app/views/definitions/_splash.html.haml**.

There is a Rails interface in which an end-user enters a word, and
then clicks various links and buttons to see the given word's
associations in various guises and forms.

There is also a React interface which invites the end-user to copy
in some of their own text, and then this interface will directly
replace (associated) words within the given text.
See: http://thesaurus-lexdump.rhcloud.com/editor

The database, whose size is over 200M in Sqlite, is not included.

The database is created from a few (open) sources and takes a good
while, and several steps, to build.

Once built the database remains intact - which makes the application
very low maintenance!

