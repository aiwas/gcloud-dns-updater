# gcloud-dns-updater

## これはなに

Google Cloud DNSのレコードを自動更新して自宅鯖とかでDDNSっぽいことをするやつ

## Google Cloud DNS 以外には対応してないの

してません

## 必要なもの

- google-cloud-sdk
- curl

## 手順

1. 「DNS管理者」ロールを付与したサービスアカウントを用意する
2. Cloud DNSでゾーンを設定する
3. 1と2を `updater.conf` に設定する
4. 以下を実行する

```sh
sudo mkdir -p /opt/gcloud-dns-updater
sudo cp update.sh /opt/gcloud-dns-updater/

sudo cp gcloud-dns-updater.* /etc/systemd/system/
sudo systemctl enable gcloud-dns-updater.service
sudo systemctl enable gcloud-dns-updater.timer
sudo systemctl start gcloud-dns-updater.timer

# sudo systemctl list-timers --all | grep "gcloud-dns-updater"
```
