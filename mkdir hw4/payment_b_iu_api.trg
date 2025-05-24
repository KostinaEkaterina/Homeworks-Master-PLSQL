create or replace trigger payment_b_iu_api
before insert or update on payment
begin
  -- проверка на выполнение команды через API
  payment_api_pack.is_changes_through_api();
end;
/