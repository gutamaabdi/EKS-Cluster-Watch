FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

RUN useradd -u 1000 -M nonrootuser

USER nonrootuser 

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 CMD curl -f http://localhost:5000/health || exit 1

CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:5000"]