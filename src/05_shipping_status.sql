DROP TABLE IF EXISTS public.shipping_status;

create table public.shipping_status
(
    shippingid int8,
    status text NOT NULL,
    state text NOT NULL,
    shipping_start_fact_datetime timestamp NOT NULL,
    shipping_end_fact_datetime timestamp NULL
);

ALTER TABLE public.shipping_status add CONSTRAINT shipping_status_p_key PRIMARY KEY (shippingid);
ALTER TABLE public.shipping_status add CONSTRAINT check_status CHECK (status in ('in_progress', 'finished'));
ALTER TABLE public.shipping_status add CONSTRAINT check_dates CHECK (shipping_start_fact_datetime <= shipping_end_fact_datetime);

INSERT INTO public.shipping_status(shippingid, status, state, shipping_start_fact_datetime, shipping_end_fact_datetime)
WITH ts AS (
    SELECT s1.shippingid,
	        first_value(s1.status) OVER (PARTITION BY shippingid ORDER BY state_datetime DESC) last_status,
	        first_value(s1.state) OVER (PARTITION BY shippingid order by state_datetime DESC) last_state,
	        max(CASE WHEN s1.state = 'booked' THEN s1.state_datetime END) OVER (PARTITION BY shippingid) start_dt,
	        max(CASE WHEN s1.state = 'recieved' THEN s1.state_datetime END) OVER (PARTITION BY shippingid) end_dt
	FROM shipping s1)
SELECT DISTINCT s.shippingid, ts.last_status, ts.last_state, ts.start_dt, ts.end_dt
FROM shipping s
LEFT JOIN ts ON s.shippingid = ts.shippingid;