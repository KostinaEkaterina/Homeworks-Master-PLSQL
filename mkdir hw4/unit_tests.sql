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
  v_create_dtime_tech payment.create_dtime_tech%type;
  v_update_dtime_tech payment.update_dtime_tech%type;
  v_payment_detail t_payment_detail_array:= t_payment_detail_array(t_payment_detail(1,'Тестовый софт'),
                                                                   t_payment_detail(2,'66.250.68.32'),
                                                                   t_payment_detail(3,'Создание'));
begin
  v_payment_id:= payment_api_pack.create_payment(v_from_client_id, v_to_client_id, v_summa, v_currency_id, v_create_dtime, v_payment_detail);
  dbms_output.put_line('payment_id: '|| v_payment_id);
 
  select create_dtime_tech, update_dtime_tech
  into v_create_dtime_tech, v_update_dtime_tech
  from payment p 
  where p.payment_id = v_payment_id;
 
  if v_create_dtime_tech <> v_update_dtime_tech then
    raise_application_error(-20998, 'Технические даты разные');
  end if;
  commit;
end;
/

select * from payment p where p.payment_id = 46;
/
select * from payment_detail pd where pd.payment_id = 46;
/

-- проверка "Перевод платежа в ошибочный статус с описанием причины"
declare
  v_payment_id  payment.payment_id%type := 85;
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
  v_payment_id  payment.payment_id%type := 85;
  v_create_dtime_tech payment.create_dtime_tech%type;
  v_update_dtime_tech payment.update_dtime_tech%type;
begin
  payment_api_pack.successful_finish_payment (v_payment_id);
 
  select create_dtime_tech, update_dtime_tech
  into v_create_dtime_tech, v_update_dtime_tech
  from payment p 
  where p.payment_id = v_payment_id;
 
  if v_create_dtime_tech = v_update_dtime_tech then
    raise_application_error(-20998, 'Технические даты равны');
  end if;
 
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
  v_payment_id  payment.payment_id%type := 85;
  v_delete_detail_ids t_number_array:= t_number_array(1,3);
begin
  payment_detail_api_pack.delete_payment_detail (v_payment_id, v_delete_detail_ids);
  commit;
end;
/
select * from payment_detail pd where pd.payment_id = 42;
/

--проверка функционала по глобальному отключению проверок. Операция удаления платежа
declare
  v_payment_id  payment.payment_id%type := -1;
begin
  common_pack.enable_manual_changes();
  
  delete from payment p where p.payment_id = -1;
  
  common_pack.disable_manual_changes();
exception
  when others then
    common_pack.disable_manual_changes();
    raise;
end;
/


--проверка функционала по глобальному отключению проверок. Операция обновления платежа
declare
  v_payment_id  payment.payment_id%type := -1;
  v_summa payment.summa%type := 1;
begin
  common_pack.enable_manual_changes();
  
  update payment p set summa = v_summa 
  where p.payment_id = v_payment_id;
  
  common_pack.disable_manual_changes();
exception
  when others then
    common_pack.disable_manual_changes();
    raise;
end;
/
--проверка функционала по глобальному отключению проверок. Операция обновления деталей платежа
declare
  v_payment_id  payment_detail.payment_id%type := -1;
begin
  common_pack.enable_manual_changes();
  update payment_detail pd set pd.field_value = 'test'
  where pd.payment_id = v_payment_id;

  common_pack.disable_manual_changes();
exception
  when others then
    common_pack.disable_manual_changes();
    raise;
end;

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
  when common_pack.e_invalid_input_parameter then
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
  when common_pack.e_invalid_input_parameter then
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
  v_payment_detail t_payment_detail_array:= t_payment_detail_array(t_payment_detail(1,'Тестовый софт'));
begin
  v_payment_id:= payment_api_pack.create_payment(v_from_client_id, v_to_client_id, v_summa, v_currency_id, v_create_dtime, v_payment_detail);
  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');
exception
  when common_pack.e_invalid_input_parameter then
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
  when common_pack.e_invalid_input_parameter then
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
  when common_pack.e_invalid_input_parameter then
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
  when common_pack.e_invalid_input_parameter then
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
  when common_pack.e_invalid_input_parameter then
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
  when common_pack.e_invalid_input_parameter then
  dbms_output.put_line('Удаление деталей платежа. Исключение возбуждено успешно. Ошибка: ' || SQLERRM);
end;
/

-- 7. проверка запрета удаления платежа через delete
declare
  v_payment_id  payment.payment_id%type := -1;
begin
  delete from payment p where p.payment_id = -1;
  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');
exception
  when common_pack.e_delete_forbidden then
    dbms_output.put_line('Удаление платежа. Исключение возбуждено успешно. Ошибка: ' || SQLERRM);
end;
/

-- 8. проверка запрета вставки в payment не через API
declare
  v_payment_id  payment.payment_id%type:= -1;
  v_summa payment.summa%type := 5000;
  v_currency_id payment.currency_id%type := 643;
  v_from_client_id payment.from_client_id%type := 1;
  v_to_client_id payment.to_client_id%type := 2;
  v_create_dtime payment.create_dtime%type := sysdate;
begin
  insert into payment (payment_id, create_dtime, summa,currency_id,from_client_id,to_client_id)
  values (v_payment_id, v_create_dtime, v_summa, v_currency_id,  v_from_client_id,v_to_client_id);
  
  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');
exception
  when common_pack.e_manual_changes then
    dbms_output.put_line('Вставка платежа. Исключение возбуждено успешно. Ошибка: ' || SQLERRM);
end;
/

-- 9. проверка запрета обновления в payment не через API
declare
  v_payment_id  payment.payment_id%type := -1;
  v_summa payment.summa%type := 1;
begin
  update payment p set summa = v_summa 
  where p.payment_id = v_payment_id;

  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');
exception
  when common_pack.e_manual_changes then
    dbms_output.put_line('Обновление платежа. Исключение возбуждено успешно. Ошибка: ' || SQLERRM);
end;
/

-- 10. проверка запрета вставки в payment_detail не через API
declare
  v_payment_id  payment_detail.payment_id%type:= -1;
begin
  insert into payment_detail (payment_id, field_id, field_value)
  values(v_payment_id, 1, 'test');
  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');
exception
  when common_pack.e_manual_changes then
    dbms_output.put_line('Вставка деталей платежа. Исключение возбуждено успешно. Ошибка: ' || SQLERRM);
end;
/

-- 11. проверка запрета обновления в payment не через API
declare
  v_payment_id  payment_detail.payment_id%type := -1;
begin
  update payment_detail pd set pd.field_value = 'test'
  where pd.payment_id = v_payment_id;

  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');
exception
  when common_pack.e_manual_changes then
    dbms_output.put_line('Обновление деталей платежа. Исключение возбуждено успешно. Ошибка: ' || SQLERRM);
end;
/

--12. негативный тест на отсутствие объекта
declare
  v_payment_id  payment.payment_id%type := -1;
  v_reason payment.status_change_reason%type := 'Тестовый перевод в ошибочный статус';
 begin
  payment_api_pack.fail_payment (v_payment_id, v_reason);
  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');
 exception
   when common_pack.e_object_notfound then
     dbms_output.put_line('Объект не найден. Исключение возбуждено успешно. Ошибка: ' || SQLERRM);
  commit;
end;
/
