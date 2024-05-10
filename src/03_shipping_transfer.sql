DROP TABLE IF EXISTS public.shipping_transfer cascade ;

CREATE TABLE public.shipping_transfer
(
    id serial,
    transfer_type varchar(5) not null,
    transfer_model varchar(20) not null,
    shipping_transfer_rate numeric(14,3) not null,
    CONSTRAINT shipping_transfer_p_key PRIMARY KEY (id)
);

ALTER TABLE public.shipping_transfer add CONSTRAINT check_shipping_transfer_rate CHECK (shipping_transfer_rate > 0 AND shipping_transfer_rate < 1);

INSERT INTO public.shipping_transfer(transfer_type, transfer_model, shipping_transfer_rate)
SELECT DISTINCT
    (regexp_split_to_array(s.shipping_transfer_description, E'\\:'))[1]::text ,
    (regexp_split_to_array(s.shipping_transfer_description, E'\\:'))[2]::text ,
    CAST ( s.shipping_transfer_rate AS DOUBLE PRECISION)
FROM public.shipping s;
