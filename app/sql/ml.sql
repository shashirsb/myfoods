BEGIN DBMS_DATA_MINING.DROP_MODEL('GB_DISH_MB');
EXCEPTION WHEN OTHERS THEN NULL; END;
/
DECLARE
  v_setlst DBMS_DATA_MINING.SETTING_LIST;
BEGIN
  v_setlst('ALGO_NAME')      := 'ALGO_APRIORI_ASSOCIATION_RULES';
  v_setlst('PREP_AUTO')      := 'ON';
  v_setlst('ASSO_MIN_SUPPORT')  := '0.04';
  v_setlst('ASSO_MIN_CONFIDENCE') := '0.1';
  v_setlst('ASSO_MAX_RULE_LENGTH'):= '2';
  v_setlst('ODMS_ITEM_ID_COLUMN_NAME'):= 'PRODUCT_NAME';
  DBMS_DATA_MINING.CREATE_MODEL2(
    MODEL_NAME    => 'GB_DISH_MB',
    MINING_FUNCTION  => 'ASSOCIATION',
    DATA_QUERY    => 'select * from ouser.fastfood_transactions',
    SET_LIST     => v_setlst,
    CASE_ID_COLUMN_NAME => 'TRANSACTION_ID');
END;