FROM python:3.13-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN python -m venv /opt/venv
RUN . /opt/venv/bin/activate && \
    pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt
COPY . .

FROM python:3.13-slim
WORKDIR /app
COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /app/account_info.py .
COPY --from=builder /app/config.py .
COPY --from=builder /app/main.py .
COPY --from=builder /app/queries.py .
COPY --from=builder /app/scheduler.py .
COPY --from=builder /app/tariff.py .
RUN addgroup --system nonroot && adduser --system --ingroup nonroot nonroot
USER nonroot
ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1
CMD ["python", "-u", "scheduler.py"]
