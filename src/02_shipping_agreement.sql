DROP TABLE IF EXISTS public.shipping_agreement cascade;

CREATE TABLE public.shipping_agreement
(
    agreementid int4 not null,
    agreement_number text not null,
    agreement_rate numeric(14,4) not null,
    agreement_commission numeric(14,4) not null,
    CONSTRAINT shipping_agreement_p_key PRIMARY KEY (agreementid)
);

ALTER TABLE public.shipping_agreement add CONSTRAINT check_agreement_rate CHECK (agreement_rate > 0 AND agreement_rate < 1);
ALTER TABLE public.shipping_agreement add CONSTRAINT check_agreement_commission CHECK (agreement_commission > 0 AND agreement_commission < 1);

INSERT INTO public.shipping_agreement(agreementid, agreement_number, agreement_rate, agreement_commission)
SELECT DISTINCT
    (regexp_split_to_array(s.vendor_agreement_description, E'\\:'))[1]::int ,
    (regexp_split_to_array(s.vendor_agreement_description, E'\\:'))[2]::text ,
    CAST((regexp_split_to_array(s.vendor_agreement_description, E'\\:'))[3] AS numeric) ,
    CAST((regexp_split_to_array(s.vendor_agreement_description, E'\\:'))[4] AS DOUBLE PRECISION)
FROM public.shipping s;