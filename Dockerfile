ARG PYTHON_VERSION=3.9
FROM python:${PYTHON_VERSION}-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app
COPY ./requirements ./requirements

ARG DEV=false
ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser && \
    python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    if [ $DEV = "true" ]; then \
      /py/bin/pip install -r ./requirements/local.txt; \
    else /py/bin/pip install -r ./requirements/production.txt; fi && \
    rm -rf /app/requirements

USER appuser

COPY . .

EXPOSE 8000

ENV PATH="/py/bin:$PATH"

CMD python manage.py runserver 0.0.0.0:8000
