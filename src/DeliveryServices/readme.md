```sh
pip install dbt
pip install dbt-databricks

dbt --version
```

```sh
DBT_PROFILES_DIR=. dbt debug
DBT_PROFILES_DIR=. dbt run
```

```sh
DBT_PROFILES_DIR=. dbt run --select views
DBT_PROFILES_DIR=. dbt build
```

```sh
DBT_PROFILES_DIR=. dbt docs generate
DBT_PROFILES_DIR=. dbt docs serve
```