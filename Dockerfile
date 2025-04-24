# Stage 1: Base build stage
FROM python:3.9.22-alpine3.21 AS builder

WORKDIR /app

COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Stage 2: Production stage
FROM python:3.9.22-alpine3.21

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1 

RUN mkdir /app

COPY --from=builder /usr/local/lib/python3.9/site-packages/ /usr/local/lib/python3.9/site-packages/
COPY --from=builder /usr/local/bin/ /usr/local/bin/
COPY ./app app/backend
COPY ./scripts app/scripts

RUN adduser --disabled-password --no-create-home appuser && \
   chown -R appuser /app && \
   chmod -R +x app/scripts

ENV PATH="/app/scripts:$PATH"

WORKDIR /app/backend

USER appuser

EXPOSE 8000

CMD [ "entrypoint.sh" ]
