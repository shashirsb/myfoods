-- As admin
create user ouser identified by MyDB__12345678; 
grant create session,create table,create sequence  to ouser;
grant unlimited tablespace to ouser;

--
create or replace FUNCTION GET_GEOMETRY (
      IN_LONGITUDE NUMBER,
      IN_LATITUDE  NUMBER
  ) RETURN SDO_GEOMETRY
      DETERMINISTIC PARALLEL_ENABLE
  IS
  BEGIN
   IF (IN_LONGITUDE IS NOT NULL 
      AND IN_LONGITUDE BETWEEN -180 AND 180
      AND IN_LATITUDE IS NOT NULL 
      AND IN_LATITUDE BETWEEN -90 AND 90)
   THEN
    RETURN 
      SDO_GEOMETRY(
        2001, 
        4326, 
        SDO_POINT_TYPE(IN_LONGITUDE, IN_LATITUDE, NULL), 
        NULL, NULL);
    ELSE RETURN NULL;
    END IF;
  END;
 /
 
create or replace function "SGTECH_PTF"(longitude in number, 
                                      latitude in number)
return SDO_GEOMETRY deterministic is
begin
  if latitude is NULL or longitude is NULL or latitude not between -90 and 90 or longitude not between -180 and 180
  then
    return NULL;
  else
     return sdo_geometry(2001, 4326, 
                sdo_point_type(longitude, latitude, NULL),NULL, NULL);
  end if;
end;
/

--

CREATE INDEX "OUSER"."SPIDX_ONLINE_S"  
   ON OUSER.ONLINE_STORES (admin.GET_GEOMETRY("LONGITUDE","LATITUDE")) 
   INDEXTYPE IS "MDSYS"."SPATIAL_INDEX_V2"  PARAMETERS ('layer_gtype=POINT cbtree_index=true');

--
grant execute on get_geometry to ouser;
grant execute on sgtech_ptf to ouser;

-- 

connect ouser/MyDB__12345678