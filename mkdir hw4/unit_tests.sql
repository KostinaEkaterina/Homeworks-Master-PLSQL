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

----негативные Unit-тесты

--1. проверка "Создание платежа"
-- Тест 1.1. ID поля не может быть пустым
declare
  v_payment_id  payment.payment_id%type;
  v_summa payment.summa%type:= 5000;
  v_currency_id payment.currency_id%type := 643;
  v_from_client_id payment.from_client_id%type := 1;
  v_to_client_id payment.to_client_id%type := 2;
  v_create_dtime payment.create_dtime%type := sysdate;
  v_payment_detail t_payment_detail_array:= t_payment_detail_array(t_payment_detail(1,'Тестовый софт'),
                                                                   t_payment_detail(2,'66.250.68.32'),
                                                                   t_payment_detail(null,'Создание'));
begin
  v_payment_id:= payment_api_pack.create_payment(v_from_client_id, v_to_client_id, v_summa, v_currency_id, v_create_dtime, v_payment_detail);
  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');
exception
  when payment_api_pack.e_invalid_input_parameter then
  dbms_output.put_line('Создание платежа. Исключение возбуждено успешно. Ошибка: ' || SQLERRM);
end;
/

-- Тест 1.2. Значение в поле не может быть пустым
declare
  v_payment_id  payment.payment_id%type;
  v_summa payment.summa%type:= 5000;
  v_currency_id payment.currency_id%type := 643;
  v_from_client_id payment.from_client_id%type := 1;
  v_to_client_id payment.to_client_id%type := 2;
  v_create_dtime payment.create_dtime%type := sysdate;
  v_payment_detail t_payment_detail_array:= t_payment_detail_array(t_payment_detail(1,'Тестовый софт'),
                                                                   t_payment_detail(2,'66.250.68.32'),
                                                                   t_payment_detail(3,null));
begin
  v_payment_id:= payment_api_pack.create_payment(v_from_client_id, v_to_client_id, v_summa, v_currency_id, v_create_dtime, v_payment_detail);
  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');
exception
  when payment_api_pack.e_invalid_input_parameter then
  dbms_output.put_line('Создание платежа. Исключение возбуждено успешно. Ошибка: ' || SQLERRM);
end;
/

-- Тест 1.3. Коллекция не содержит данных
declare
  v_payment_id  payment.payment_id%type;
  v_summa payment.summa%type:= 5000;
  v_currency_id payment.currency_id%type := 643;
  v_from_client_id payment.from_client_id%type := 1;
  v_to_client_id payment.to_client_id%type := 2;
  v_create_dtime payment.create_dtime%type := sysdate;
  v_payment_detail t_payment_detail_array:= t_payment_detail_array();
begin
  v_payment_id:= payment_api_pack.create_payment(v_from_client_id, v_to_client_id, v_summa, v_currency_id, v_create_dtime, v_payment_detail);
  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');
exception
  when payment_api_pack.e_invalid_input_parameter then
  dbms_output.put_line('Создание платежа. Исключение возбуждено успешно. Ошибка: ' || SQLERRM);
end;
/



-- 2. проверка "Перевод платежа в ошибочный статус с описанием причины"
-- Тест 2.1. ID платежа не передан
declare
  v_payment_id  payment.payment_id%type := null;
  v_reason payment.status_change_reason%type := 'Тестовый перевод в ошибочный статус';
begin
  payment_api_pack.fail_payment (v_payment_id, v_reason);
  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');
exception
  when payment_api_pack.e_invalid_input_parameter then
  dbms_output.put_line('Перевод платежа в ошибочный статус. Исключение возбуждено успешно. Ошибка: ' || SQLERRM);
end;
/

-- 3. проверка "Отмена платежа"
-- Тест 3.1. Причина не передана
declare
  v_payment_id  payment.payment_id%type := 47;
begin
  payment_api_pack.cancel_payment (v_payment_id, null);
  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');
exception
  when payment_api_pack.e_invalid_input_parameter then
  dbms_output.put_line('Отмена платежа. Исключение возбуждено успешно. Ошибка: ' || SQLERRM);
end;
/

-- 4. проверка "Завершение платежа"
-- Тест 4.1. ID платежа не передан
declare
  v_payment_id  payment.payment_id%type := null;
begin
  payment_api_pack.successful_finish_payment (v_payment_id);
  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');
exception
  when payment_api_pack.e_invalid_input_parameter then
  dbms_output.put_line('Завершение платежа. Исключение возбуждено успешно. Ошибка: ' || SQLERRM);
end;
/

-- 5 проверка "Добавление или обновление данных платежа"
-- Тест 5.1. ID поля не может быть пустым
declare
  v_payment_id  payment.payment_id%type := 48;
  v_payment_detail t_payment_detail_array:= t_payment_detail_array(t_payment_detail(null,'66.250.68.32'),
                                                                   t_payment_detail(3,'Обновление'));
begin
  payment_detail_api_pack.insert_or_update_payment_detail (v_payment_id, v_payment_detail);
  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');
exception
  when payment_api_pack.e_invalid_input_parameter then
  dbms_output.put_line('Добавление или обновление данных платежа. Исключение возбуждено успешно. Ошибка: ' || SQLERRM);
end;
/

-- 6 проверка "Удаление деталей платежа"
-- Тест 6.1. ID объекта не может быть пустым
declare
  v_payment_id  payment.payment_id%type := null;
  v_delete_detail_ids t_number_array:= t_number_array(1,2);
begin
  payment_detail_api_pack.delete_payment_detail (v_payment_id, v_delete_detail_ids);
  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');
exception
  when payment_api_pack.e_invalid_input_parameter then
  dbms_output.put_line('Удаление деталей платежа. Исключение возбуждено успешно. Ошибка: ' || SQLERRM);
end;
/