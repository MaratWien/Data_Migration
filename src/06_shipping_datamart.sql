CREATE OR REPLACE view public.shipping_datamart AS
(
    SELECT si.shippingid, si.vendorid, si.transfer_type_id,
        (DATE_PART('day', ss.shipping_end_fact_datetime - ss.shipping_start_fact_datetime))::int as full_day_at_shipping,
        coalesce((ss.shipping_end_fact_datetime > si.shipping_plan_datetime), false) as is_delay,
        (ss.status = 'finished') AS is_shipping_finish,
        (CASE WHEN ss.shipping_end_fact_datetime > si.shipping_plan_datetime THEN
	    DATE_PART('day', ss.shipping_end_fact_datetime - si.shipping_plan_datetime)end)::int AS delay_day_at_shipping,
        si.payment_amount,
        si.payment_amount*(cr.shipping_country_base_rate+sa.agreement_rate+st.shipping_transfer_rate) AS vat,
        si.payment_amount*agreement_commission AS profit
    FROM public.shipping_info si
    LEFT JOIN public.shipping_status ss ON ss.shippingid = si.shippingid
    LEFT JOIN public.shipping_agreement sa ON sa.agreementid = si.agreementid
    LEFT JOIN public.shipping_country_rates cr ON cr.id = si.shipping_country_id
    LEFT JOIN public.shipping_transfer st ON st.id = si.transfer_type_id
 );