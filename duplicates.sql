with vills as (
SELECT  t1.feature_id,
		t1.unparsed_name, 
		t2.feature_id as district_fid, 
		t1.vendor_feature_id,
		ST_ENVELOPE(t1.geom) AS bbox
FROM khaled_tha.tha_territory_01242024 t1
JOIN khaled_tha.tha_territory_01242024 t2
ON st_within(t1.geom, t2.geom)
WHERE (t1.is_active ='true' or t1.is_active is null)
AND t2.is_active ='true'
AND t1.territory_type = 'VILLAGE'
AND t2.territory_type = 'DISTRICT'
)
results as (
select
	a.district_fid,
	a.unparsed_name,	
	a.feature_id as FID1,
	concat(a.unparsed_name || ' ' || c.moo_e_pf || ' ' || c.moo_no) new_name1,
 	b.feature_id as FID2,
	concat(a.unparsed_name || ' ' || d.moo_e_pf || ' ' || d.moo_no) new_name2,
 	ST_DISTANCE(a.bbox,b.bbox,true) as dist
FROM vills a JOIN vills b
ON a.unparsed_name = b.unparsed_name
AND a.feature_id > b.feature_id
AND ST_DWithin(a.bbox, b.bbox, 1000, true)
JOIN tha_khx_ingest_raw.village_point_702884158908661760 c
on split_part(a.vendor_feature_id, '_', 2) = c.village_id
JOIN tha_khx_ingest_raw.village_point_702884158908661760 d
on split_part(b.vendor_feature_id, '_', 2) = d.village_id
order by district_fid, unparsed_name
)
select distinct district_fid, unparsed_name, fid1, new_name1
from results
union
select distinct district_fid, unparsed_name, fid2, new_name2
from results