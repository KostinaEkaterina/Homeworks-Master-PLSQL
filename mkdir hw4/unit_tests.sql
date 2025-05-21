/*
Автор: Костина Екатерина
Заготовка под UNIT-тесты
*/

--проверка "Создание платежа"
declare
  v_payment_id  payment.payment_id%type;
  v_summa payment.summa%type := 5000;
  v_currency_id payment.currency_id%type := 643;
  v_from_client_id payment.from_client_id%type := 1;
  v_to_client_id payment.to_client_id%type := 2;
  v_create_dtime payment.create_dtime%type := sysdate;
  v_payment_detail t_payment_detail_array:= t_payment_detail_array(t_payment_detail(1,'Тестовый софт'),
                                                                   t_payment_detail(2,'66.250.68.32'),
                                                                   t_payment_detail(3,'Создание'));
begin
  v_payment_id:= payment_api_pack.create_payment(v_from_client_id, v_to_client_id, v_summa, v_currency_id, v_create_dtime, v_payment_detail);
  dbms_output.put_line('payment_id: '|| v_payment_id);
  commit;
end;
/

select * from payment p where p.payment_id = 46;
/
select * from payment_detail pd where pd.payment_id = 46;
/

-- проверка "Перевод платежа в ошибочный статус с описанием причины"
declare
  v_payment_id  payment.payment_id%type := 46;
  v_reason payment.status_change_reason%type := 'Тестовый перевод в ошибочный статус';
begin
  payment_api_pack.fail_payment (v_payment_id, v_reason);
  commit;
end;
/
select * from payment p where p.payment_id = 46;
/
-- проверка "Отмена платежа"
declare
  v_payment_id  payment.payment_id%type := 47;
  v_reason payment.status_change_reason%type := 'Тестовый перевод в отмененный статус';
begin
  payment_api_pack.cancel_payment (v_payment_id, v_reason);
  commit;
end;
/
select * from payment p where p.payment_id = 47;
/
--проверка "Завершение платежа"
declare
  v_payment_id  payment.payment_id%type := 48;
begin
  payment_api_pack.successful_finish_payment (v_payment_id);
  commit;
end;
/
select * from payment p where p.payment_id = 48;
/
--проверка "Добавление или обновление данных платежа"
declare
  v_payment_id  payment.payment_id%type := 48;
  v_payment_detail t_payment_detail_array:= t_payment_detail_array(t_payment_detail(2,'66.250.68.32'),
                                                                   t_payment_detail(3,'Обновление'));
begin
  payment_detail_api_pack.insert_or_update_payment_detail (v_payment_id, v_payment_detail);
  commit;
end;
/
select * from payment_detail pd where pd.payment_id = 48;
/
--проверка "Удаление деталей платежа"
declare
  v_payment_id  payment.payment_id%type := 48;
  v_delete_detail_ids t_number_array:= t_number_array(1,3);
begin
  payment_detail_api_pack.delete_payment_detail (v_payment_id, v_delete_detail_ids);
  commit;
end;
/
select * from payment_detail pd where pd.payment_id = 42;
/