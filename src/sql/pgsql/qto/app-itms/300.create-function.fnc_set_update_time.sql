CREATE OR REPLACE FUNCTION "fnc_set_update_time" () RETURNS trigger AS '
	BEGIN
		NEW.update_time = DATE_TRUNC(''second'', NOW());
		RETURN NEW;
	END;'
LANGUAGE "plpgsql";

SELECT 'fnc_set_update_time exists is ' || exists(SELECT * FROM pg_proc WHERE proname='fnc_set_update_time')
;