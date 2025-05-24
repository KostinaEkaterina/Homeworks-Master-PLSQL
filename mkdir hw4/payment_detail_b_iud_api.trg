create or replace trigger payment_detail_b_iud_api 
before insert or update on payment_detail
begin
  -- проверка на выполнение команды через API
  payment_detail_api_pack.is_changes_through_api();
end;
/