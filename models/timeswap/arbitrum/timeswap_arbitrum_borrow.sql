{{ config(
    alias = 'borrow',
    materialized = 'incremental',
    file_format = 'delta',
    incremental_strategy = 'merge',
    unique_key = ['Transaction_Hash'],
    post_hook='{{ expose_spells(\'["arbitrum"]\',
                                "project",
                                "timeswap",
                                \'["raveena15, varunhawk19"]\') }}'
    )
}}


SELECT
  b.evt_tx_hash as Transaction_Hash,
  b.evt_block_time as Time,
  b.isToken0 as Token_0,
  b.maturity as maturity,
  b.strike as strike, 
  i.pool_pair as Pool_Pair,
  i.chain as Chain,
  CAST(
    CASE
      WHEN CAST(b.isToken0 AS BOOLEAN) = true THEN CAST(b.tokenAmount AS DOUBLE) / power(10,i.token0_decimals)
      ELSE CAST(b.tokenAmount AS DOUBLE) / power(10,i.token1_decimals)
    END as DOUBLE
  ) as Token_Amount,
  CAST(
    CASE
      WHEN CAST(b.isToken0 AS BOOLEAN) = true THEN CAST(b.tokenAmount AS DOUBLE) / power(10,i.token0_decimals) * p.price
      ELSE CAST(b.tokenAmount AS DOUBLE) / power(10,i.token1_decimals) * p.price
    END as DOUBLE
  ) as USD_Amount
  FROM {{ source('timeswap_arbitrum', 'TimeswapV2PeripheryUniswapV3BorrowGivenPrincipal_evt_BorrowGivenPrincipal') }} b
  JOIN {{ ref('timeswap_arbitrum_pools') }} i ON CAST(b.maturity as VARCHAR(100)) = i.maturity and cast(b.strike as VARCHAR(100)) = i.strike
  JOIN {{ source('prices', 'usd') }} p ON p.minute = date_trunc('minute', b.evt_block_time)
  WHERE p.symbol=i.token0_symbol AND p.blockchain = 'arbitrum' AND b.isToken0 = true
  {% if is_incremental() %}
    AND b.evt_block_time >= date_trunc("day", now() - interval '1 week')
  {% endif %}

UNION
 
SELECT
  b.evt_tx_hash as Transaction_Hash,
  b.evt_block_time as Time,
  b.isToken0 as Token_0,
  b.maturity as maturity,
  b.strike as strike,
  i.pool_pair as Pool_Pair,
  i.chain as Chain,
  CAST(
    CASE
      WHEN CAST(b.isToken0 AS BOOLEAN) = true THEN CAST(b.tokenAmount AS DOUBLE) / power(10,i.token0_decimals)
      ELSE CAST(b.tokenAmount AS DOUBLE) / power(10,i.token1_decimals)
    END as DOUBLE
  ) as Token_Amount,
  CAST(
    CASE
      WHEN CAST(b.isToken0 AS BOOLEAN) = true THEN CAST(b.tokenAmount AS DOUBLE) / power(10,i.token0_decimals) * p.price
      ELSE CAST(b.tokenAmount AS DOUBLE) / power(10,i.token1_decimals) * p.price
    END as DOUBLE
  ) as USD_Amount
  FROM {{ source('timeswap_arbitrum', 'TimeswapV2PeripheryUniswapV3BorrowGivenPrincipal_evt_BorrowGivenPrincipal') }} b
  JOIN {{ ref('timeswap_arbitrum_pools') }} i ON CAST(b.maturity as VARCHAR(100)) = i.maturity and cast(b.strike as VARCHAR(100)) = i.strike
  JOIN {{ source('prices', 'usd') }} p ON p.minute = date_trunc('minute', b.evt_block_time)
  WHERE p.symbol=i.token1_symbol AND p.blockchain = 'arbitrum' AND b.isToken0 = false
  {% if is_incremental() %}
    AND b.evt_block_time >= date_trunc("day", now() - interval '1 week')
  {% endif %}


UNION

SELECT
  b.evt_tx_hash as Transaction_Hash,
  b.evt_block_time as Time,
  b.isToken0 as Token_0,
  b.maturity as maturity,
  b.strike as strike,
  i.pool_pair as Pool_Pair,
  i.chain as Chain,
  CAST(
    CASE
      WHEN CAST(b.isToken0 AS BOOLEAN) = true THEN CAST(b.tokenAmount AS DOUBLE) / power(10,i.token0_decimals)
      ELSE CAST(b.tokenAmount AS DOUBLE) / power(10,i.token1_decimals)
    END as DOUBLE
  ) as Token_Amount,
  CAST(
    CASE
      WHEN CAST(b.isToken0 AS BOOLEAN) = true THEN CAST(b.tokenAmount AS DOUBLE) / power(10,i.token0_decimals) * p.price
      ELSE CAST(b.tokenAmount AS DOUBLE) / power(10,i.token1_decimals) * p.price
    END as DOUBLE
  ) as USD_Amount
  FROM {{ source('timeswap_arbitrum', 'TimeswapV2PeripheryNoDexBorrowGivenPrincipal_evt_BorrowGivenPrincipal') }} b
  JOIN {{ ref('timeswap_arbitrum_pools') }} i ON CAST(b.maturity as VARCHAR(100)) = i.maturity and cast(b.strike as VARCHAR(100)) = i.strike
  JOIN {{ source('prices', 'usd') }} p ON p.minute = date_trunc('minute', b.evt_block_time)
  WHERE p.symbol=i.token0_symbol AND p.blockchain = 'arbitrum' AND b.isToken0 = true
  {% if is_incremental() %}
    AND b.evt_block_time >= date_trunc("day", now() - interval '1 week')
  {% endif %}

UNION
 
SELECT
  b.evt_tx_hash as Transaction_Hash,
  b.evt_block_time as Time,
  b.isToken0 as Token_0,
  b.maturity as maturity,
  b.strike as strike,
  i.pool_pair as Pool_Pair,
  i.chain as Chain,
  CAST(
    CASE
      WHEN CAST(b.isToken0 AS BOOLEAN) = true THEN CAST(b.tokenAmount AS DOUBLE) / power(10,i.token0_decimals)
      ELSE CAST(b.tokenAmount AS DOUBLE) / power(10,i.token1_decimals)
    END as DOUBLE
  ) as Token_Amount,
  CAST(
    CASE
      WHEN CAST(b.isToken0 AS BOOLEAN) = true THEN CAST(b.tokenAmount AS DOUBLE) / power(10,i.token0_decimals) * p.price
      ELSE CAST(b.tokenAmount AS DOUBLE) / power(10,i.token1_decimals) * p.price
    END as DOUBLE
  ) as USD_Amount
  FROM {{ source('timeswap_arbitrum', 'TimeswapV2PeripheryNoDexBorrowGivenPrincipal_evt_BorrowGivenPrincipal') }} b
  JOIN {{ ref('timeswap_arbitrum_pools') }} i ON CAST(b.maturity as VARCHAR(100)) = i.maturity and cast(b.strike as VARCHAR(100)) = i.strike
  JOIN {{ source('prices', 'usd') }} p ON p.minute = date_trunc('minute', b.evt_block_time)
  WHERE p.symbol=i.token0_symbol AND p.blockchain = 'arbitrum' AND b.isToken0 = true
  {% if is_incremental() %}
    AND b.evt_block_time >= date_trunc("day", now() - interval '1 week')
  {% endif %}


