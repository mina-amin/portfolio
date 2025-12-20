# Forty Website (Dockerized)

This project runs the **Forty** website template (by HTML5 UP) inside a Docker container.

The website is served on **port 80** and is based on the official Forty demo.

---

## 🌐 Demo

You can view the original Forty demo here:

👉 [https://html5up.net/forty](https://html5up.net/forty)

---

## 🐳 Docker Image

Docker Hub repository:

```
minaamin/forty
```

---

## 🚀 Running the Container

Pull the image from Docker Hub:

```bash
docker pull minaamin/forty
```

Run the container:

```bash
docker run -d \
  -p 80:80 \
  --name forty-website \
  minaamin/forty
```

Then open your browser and visit:

```
http://localhost
```

---

## ⚙️ Exposed Port

* **80** – HTTP (website access)

---

## 📦 About Forty

**Forty** is a clean, responsive HTML5 template designed by **HTML5 UP**.
It is suitable for portfolios, landing pages, and modern websites.

Original source:
[https://html5up.net/forty](https://html5up.net/forty)

---

## 📄 License

The Forty template is licensed under the **Creative Commons Attribution 3.0 License**.

Please refer to HTML5 UP for full license details.

---

## 👤 Author

Docker image maintained by:

**minaamin**


