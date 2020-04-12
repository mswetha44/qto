TRUNCATE TABLE items_roles_permissions ;
INSERT INTO items_roles_permissions ( roles_guid,meta_tables_guid,meta_routes_guid,name,description) 
   SELECT roles.guid , t2.guid, t3.guid
		, roles.name || '__' || t3.name || '__ON__' || t2.name as name
		, 'WHETHER OR NOT THE ' || roles.name || ' CAN ' || t3.name || ' THE ' || t2.name as name
   from roles
   cross join (
      SELECT meta_tables.guid , meta_tables.name 
         FROM meta_tables
         WHERE 1=1 
         and meta_tables.name not like 'test_%'
         and meta_tables.name not like '%_2018%'
         and meta_tables.name not like '%_2018'
         and meta_tables.name not like '%_2019%'
         and meta_tables.name not like '%_2019'
         and meta_tables.name not like '%_2020%'
         and meta_tables.name not like '%_2020'
         ) t2
   cross join (
      SELECT meta_routes.guid , meta_routes.name FROM meta_routes) t3
;

-- the query and search routes apply to all the items - should use the all fake item
DELETE FROM items_roles_permissions WHERE 1=1 
   AND meta_tables_guid NOT IN 
   ( SELECT guid from meta_tables WHERE name = 'all')
   AND meta_routes_guid IN 
   ( SELECT guid from meta_routes WHERE name IN ('query' , 'search'))
; 

-- deny anything related to roles and users to all but the product instance owner
UPDATE items_roles_permissions set allowed=false
WHERE 1=1
AND ( name not like '%userstories%')
AND ( name like '%roles%' or name like '%users%' or name like '%items_roles_permissions%' 
      or name like '%meta_tables%' or name like '%meta_routes%' 
    )
;

-- the PRODUCT_INSTANCE_OWNER MUST see EVERYTHING
UPDATE items_roles_permissions set allowed=true
WHERE 1=1
   AND roles_guid IN 
   ( SELECT guid from roles WHERE name = 'PRODUCT_INSTANCE_OWNER')
;

-- any combination of view with item not ending with _doc is pointless 
DELETE FROM items_roles_permissions 
WHERE 1=1
AND ( name like '%::view%' and name not like '%_doc')
; 

-- and display the "forbidden ones"
SELECT roles.name , items_roles_permissions.allowed , meta_routes.name , meta_tables.name 
FROM items_roles_permissions
LEFT JOIN roles ON roles.guid = roles_guid
LEFT JOIN meta_routes ON meta_routes.guid = meta_routes_guid
LEFT JOIN meta_tables ON meta_tables.guid = meta_tables_guid
WHERE items_roles_permissions.allowed = 'false'
;


