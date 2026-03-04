CREATE OR REPLACE TABLE `{{ params.project }}.{{ params.dataset }}.{{ params.target_table }}`
CLUSTER BY user_id, category AS
WITH base AS (
  SELECT
    order_id,
    user_id,
    product_id,
    name,
    category,
    price,
    quantity,
    total_price,
    stock,
    price_tier,
    order_dt
  FROM `{{ params.project }}.{{ params.dataset }}.{{ params.source_table }}`
  WHERE quantity > 0
),
typed AS (
  SELECT
    order_id,
    user_id,
    product_id,
    name,
    category,
    price,
    quantity,
    total_price,
    stock,
    price_tier,
    CAST(order_dt AS DATE) AS order_dt_part
  FROM base
),
dedup AS (
  SELECT
    t.*,
    ROW_NUMBER() OVER (
      PARTITION BY order_id, product_id
      ORDER BY order_dt_part DESC
    ) AS rn
  FROM typed t
)
SELECT
  order_id,
  user_id,
  product_id,
  name,
  category,
  price,
  quantity,
  total_price,
  stock,
  price_tier,
  order_dt_part AS order_dt
FROM dedup
WHERE rn = 1;