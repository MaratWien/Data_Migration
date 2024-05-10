DROP TABLE IF EXISTS public.shipping_country_rates CASCADE;

CREATE TABLE public.shipping_country_rates
(
    id serial,
    shipping_country text NOT NULL UNIQUE,
    shipping_country_base_rate numeric(14,3) NOT NULL CHECK (shipping_country_base_rate > 0 and shipping_country_base_rate < 1),
    CONSTRAINT shipping_country_rates_p_key PRIMARY KEY (id)
);

INSERT INTO public.shipping_country_rates(shipping_country, shipping_country_base_rate)
SELECT DISTINCT s.shipping_country, s.shipping_country_base_rate
FROM shipping s ;
--- test table
SELECT *
FROM public.shipping_country_rates
LIMIT 5;