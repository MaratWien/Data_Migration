DROP TABLE IF EXISTS public.shipping_info ;

CREATE TABLE public.shipping_info
(
    shippingid int8,
    vendorid bigint NULL,
    payment_amount numeric(14,2) NULL,
    shipping_plan_datetime timestamp NULL,
    transfer_type_id int8 not null,
    shipping_country_id int8 not null,
    agreementid int8 not null,
    CONSTRAINT shipping_info_p_key PRIMARY KEY (shippingid)
);

ALTER TABLE public.shipping_info add CONSTRAINT shipping_info_transfer_type_id_fkey FOREIGN KEY (transfer_type_id) REFERENCES shipping_transfer(id);
ALTER TABLE public.shipping_info add CONSTRAINT shipping_info_shipping_country_id_fkey FOREIGN KEY (shipping_country_id) REFERENCES shipping_country_rates(id);
ALTER TABLE public.shipping_info add CONSTRAINT shipping_agreementid_fkey FOREIGN KEY (agreementid) REFERENCES shipping_agreement(agreementid);
ALTER TABLE public.shipping_info add CONSTRAINT check_payment_amount CHECK (payment_amount > 0);

INSERT INTO public.shipping_info(shippingid, vendorid, payment_amount, shipping_plan_datetime, transfer_type_id, shipping_country_id, agreementid)
WITH st AS (
    SELECT id AS transfer_type_id,
            transfer_type,
            transfer_model
    FROM shipping_transfer
), scr AS (
    SELECT id AS shipping_country_id, shipping_country
	FROM shipping_country_rates t
)
SELECT DISTINCT
    s.shippingid, s.vendorid, s.payment_amount, s.shipping_plan_datetime,
	st.transfer_type_id, scr.shipping_country_id,
	(regexp_split_to_array(s.vendor_agreement_description, E'\\:'))[1]::int
FROM shipping s
LEFT JOIN st ON (regexp_split_to_array(s.shipping_transfer_description, E'\\:'))[1]::text = st.transfer_type
	AND (regexp_split_to_array(s.shipping_transfer_description, E'\\:'))[2]::text = st.transfer_model
LEFT JOIN scr ON s.shipping_country = scr.shipping_country;