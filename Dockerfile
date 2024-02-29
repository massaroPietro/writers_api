ARG PYTHON_VERSION=3.9
FROM python:${PYTHON_VERSION}-alpine

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app
COPY ./requirements ./requirements


ARG DEV=false
RUN adduser \
    --disabled-password \
    --no-create-home \
    appuser && \
    python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
      build-base postgresql-dev musl-dev && \
    if [ $DEV = "true" ]; then \
      /py/bin/pip install -r ./requirements/local.txt; \
    else /py/bin/pip install -r ./requirements/production.txt; fi && \
    rm -rf /app/requirements && \
    apk del .tmp-build-deps

USER appuser

COPY .flake8 .
COPY writers_api .

EXPOSE 8000

ENV PATH="/py/bin:$PATH"

CMD python manage.py migrate && python manage.py runserver 0.0.0.0:8000
