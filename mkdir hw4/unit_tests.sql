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
  v_payment_detail t_payment_detail_array:= t_payment_detail_array(t_payment_detail(1,'Тестовый софт'),
                                                                   t_payment_detail(2,'66.250.68.32'),
                                                                   t_payment_detail(3,'Создание'));
begin
  v_payment_id:= create_payment(v_from_client_id, v_to_client_id, v_summa, v_currency_id, v_payment_detail);
  dbms_output.put_line('payment_id: '|| v_payment_id);
  commit;
end;
/

select * from payment p where p.payment_id = 42;
/
select * from payment_detail pd where pd.payment_id = 42;
/

-- проверка "Перевод платежа в ошибочный статус с описанием причины"
declare
  v_payment_id  payment.payment_id%type := 42;
  v_reason payment.status_change_reason%type := 'Тестовый перевод в ошибочный статус';
begin
  fail_payment (v_payment_id, v_reason);
  commit;
end;
/
select * from payment p where p.payment_id = 42;
/
-- проверка "Отмена платежа"
declare
  v_payment_id  payment.payment_id%type := 43;
  v_reason payment.status_change_reason%type := 'Тестовый перевод в отмененный статус';
begin
  cancel_payment (v_payment_id, v_reason);
  commit;
end;
/
select * from payment p where p.payment_id = 43;
/
--проверка "Завершение платежа"
declare
  v_payment_id  payment.payment_id%type := 44;
begin
  successful_finish_payment (v_payment_id);
  commit;
end;
/
select * from payment p where p.payment_id = 44;
/
--проверка "Добавление или обновление данных платежа"
declare
  v_payment_id  payment.payment_id%type := 42;
  v_payment_detail t_payment_detail_array:= t_payment_detail_array(t_payment_detail(2,'66.250.68.32'),
                                                                   t_payment_detail(3,'Обновление'));
begin
  insert_or_update_payment_detail (v_payment_id, v_payment_detail);
  commit;
end;
/
select * from payment_detail pd where pd.payment_id = 42;
/
--проверка "Удаление деталей платежа"
declare
  v_payment_id  payment.payment_id%type := 42;
  v_delete_detail_ids t_number_array:= t_number_array(1,3);
begin
  delete_payment_detail (v_payment_id, v_delete_detail_ids);
  commit;
end;
/
select * from payment_detail pd where pd.payment_id = 42;
/