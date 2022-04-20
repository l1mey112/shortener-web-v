echo ------- Building Vite App! -------
build/build.sh

echo ""
echo ------- Building V Binary! -------
v -prod -gc boehm . -o shortener-web-app
echo done!
echo ""
echo ----- Packaging Application ------

rm shortener-all.tar.gz
tar -cvzf shortener-all.tar.gz shortener-web-app templates/

rm shortener-web-app
#! remember to flush redis cache