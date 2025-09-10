# Symfony + Docker "Empty Project" Setup

⚡️ **Full details and explanations are in the article**: [https://blog.gl.net.ua/articles/symfony-docker-empty-project/](https://blog.gl.net.ua/articles/symfony-docker-empty-project/)  
This repository only contains the ready-to-run source code.

---

This project provides a clean, minimal Symfony environment running inside Docker containers.  
It includes:
- Symfony 7.3 (via skeleton)
- PHP 8.2 with Composer and `pdo_mysql`
- MySQL 8.4, preconfigured with init scripts and strict settings
- Docker Compose orchestration

The goal is to have a predictable, reproducible baseline for experiments, benchmarks, and article examples.  
Use `init.sh` to bootstrap everything — the script will build containers, install Symfony, and configure the database connection automatically.