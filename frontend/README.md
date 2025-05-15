# frontend

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

Deployment
git add .
git commit -m ""
git push origin main

ssh root@152.53.255.176
cd /opt/KiForKids
git pull origin main

cd /opt/KiForKids/backend
docker-compose down
docker-compose up --build -d

sudo nginx -t && sudo systemctl reload nginx

flutter build web
scp -r build/web/* root@152.53.255.176:/var/www/kiforkids

deploy.sh

./deploy.sh

./status_remote.sh

./deploy_frontend_only.sh "Deine Commit"
