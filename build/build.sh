cd "./public/"
npm run build
cd ..

rm -r ./templates
mkdir templates
mv ./public/dist/** ./templates