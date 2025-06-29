/*
Автор: Костина Екатерина
Описание скрипта: API для сущностей “Платеж” и “Детали платежа”
*/
-- Создание платежа
create or replace function create_payment (p_from_client_id payment.from_client_id%type,
                                           p_to_client_id payment.to_client_id%type,
                       p_summa payment.summa%type,
                       p_currency_id payment.currency_id%type,
                                           p_payment_detail t_payment_detail_array) return payment.payment_id%type
is
  v_payment_id  payment.payment_id%type;
  v_message varchar2(200 char) := 'Платеж создан';
  c_new_status constant payment.status%type := 0;
  v_current_dtime date := systimestamp;
begin
  
  if p_payment_detail is not empty then
  
    for i in p_payment_detail.first..p_payment_detail.last loop 
  
      if (p_payment_detail(i).field_id is null) then
        dbms_output.put_line ('ID поля не может быть пустым');
      end if;
  
      if (p_payment_detail(i).field_value is null) then
        dbms_output.put_line ('Значение в поле не может быть пустым');
      end if;
     
    end loop;
   
  else
    dbms_output.put_line ('Коллекция не содержит данных');
  end if;
  
  dbms_output.put_line (v_message || '. Статус: ' || c_new_status || '. ID: ' || v_payment_id);
  dbms_output.put_line (to_char(v_current_dtime,'dd.mm.yyyy hh24:mm:ss'));
 
  --создание платежа
  insert into payment (payment_id, create_dtime, summa,currency_id,from_client_id,to_client_id)
  values (payment_seq.nextval, v_current_dtime, p_summa, p_currency_id,  p_from_client_id,p_to_client_id)
  returning payment_id into v_payment_id;
 
  dbms_output.put_line ('Создан новый payment: ' || v_payment_id);
 
  --добавление данных о платеже
 
  insert into payment_detail (payment_id, field_id, field_value)
  select v_payment_id, value(p).field_id, value(p).field_value
  from table(p_payment_detail) p;

  return v_payment_id;
  
end create_payment;
/


-- Перевод платежа в ошибочный статус с описанием причины
create or replace procedure fail_payment (p_payment_id payment.payment_id%type,
                                          p_reason payment.status_change_reason%type)
is
  v_message varchar2(200 char) := 'Сброс платежа в "ошибочный статус" с указанием причины';
  c_error_status constant payment.status%type := 2;
  v_current_dtime date := sysdate;
begin
  if p_payment_id is null then
    dbms_output.put_line ('ID объекта не может быть пустым');
  end if;
  
  if p_reason is null then
    dbms_output.put_line ('Причина не может быть пустой');
  end if;
 
  --обновление статуса платежа
  update payment p 
  set p.status = c_error_status,
      p.status_change_reason  = p_reason
  where p.payment_id = p_payment_id
    and p.status = 0; 
     
  --если было произвенено обновление, выводим информацию
  if sql%rowcount > 0 then
    dbms_output.put_line (v_message || '. Статус: '|| c_error_status ||'. Причина: ' || p_reason || '. ID: ' || p_payment_id);
    dbms_output.put_line (to_char(v_current_dtime,'dd.mm.yyyy hh24:mm:ss'));
  --если не было, то выводим информацию об ошибке
  else 
    dbms_output.put_line ('Ошибка. Статус платежа не в статусе "Создан". ID платежа: ' || p_payment_id);
  end if;
 
end fail_payment;
/
-- Отмена платежа
create or replace procedure cancel_payment (p_payment_id  payment.payment_id%type,
                                            p_reason payment.status_change_reason%type)
is
  v_message varchar2(200 char) := 'Отмена платежа с указанием причины';
  c_cancel_status constant payment.status%type := 3;
  v_current_dtime date := sysdate;
begin
  if p_payment_id is null then
    dbms_output.put_line ('ID объекта не может быть пустым');
  end if;
  
  if p_reason is null then
    dbms_output.put_line ('Причина не может быть пустой');
  end if;
 
  update payment p 
  set p.status = c_cancel_status,
      p.status_change_reason  = p_reason
  where p.payment_id = p_payment_id
    and p.status = 0;
     
  --если было произвенено обновление, выводим информацию
  if sql%rowcount > 0 then
    dbms_output.put_line (v_message || '. Статус: ' || c_cancel_status|| '. Причина: ' || p_reason || '. ID: ' || p_payment_id);
    dbms_output.put_line (to_char(v_current_dtime,'dd.mm.yyyy hh24:mm:ss'));
  --если не было, то выводим информацию об ошибке
  else 
    dbms_output.put_line ('Ошибка. Статус платежа не в статусе "Создан". ID платежа: ' || p_payment_id);
  end if;
end cancel_payment;
/
-- Завершение платежа
create or replace procedure successful_finish_payment (p_payment_id payment.payment_id%type)
is
  v_message varchar2(200 char) := 'Успешное завершение платежа';
  c_success_status constant payment.status%type := 1;
  v_current_dtime date := sysdate;
begin
  if p_payment_id is null then
    dbms_output.put_line ('ID объекта не может быть пустым');
  end if;
 
  --обновление статуса платежа
  update payment p 
  set p.status = c_success_status
  where p.payment_id = p_payment_id
    and p.status = 0;
 
  --если было произвенено обновление, выводим информацию
  if sql%rowcount > 0 then
    dbms_output.put_line (v_message || '. Статус: ' || c_success_status);
    dbms_output.put_line (to_char(v_current_dtime,'dd.mm.yyyy hh24:mm:ss'));
  else 
    dbms_output.put_line ('Ошибка. Статус платежа не в статусе "Создан". ID платежа: ' || p_payment_id);
  end if;
end successful_finish_payment;
/
-- Добавление или обновление данных платежа
create or replace procedure insert_or_update_payment_detail (p_payment_id payment.payment_id%type,
                                                             p_payment_detail t_payment_detail_array)
is
  v_message varchar2(200 char) := 'Данные платежа добавлены или обновлены по списку id_поля/значение';
  v_current_dtime timestamp := systimestamp;
begin
  if p_payment_id is null then
    dbms_output.put_line ('ID объекта не может быть пустым');
  end if;
  
  if p_payment_detail is not empty then
  
    for i in p_payment_detail.first..p_payment_detail.last loop 
  
      if (p_payment_detail(i).field_id is null) then
        dbms_output.put_line ('ID поля не может быть пустым');
      end if;
  
      if (p_payment_detail(i).field_value is null) then
        dbms_output.put_line ('Значение в поле не может быть пустым');
      end if;
     
    end loop;
   
  else
    dbms_output.put_line ('Коллекция не содержит данных');
  end if;
  
  dbms_output.put_line (v_message || '. ID: ' || p_payment_id);
  dbms_output.put_line (to_char(v_current_dtime,'dd.mm.yyyy hh24:mm:ss.ff'));
 
  merge into payment_detail pd 
  using (select p_payment_id payment_id,
                value(p).field_id field_id,
                value(p).field_value field_value
         from table(p_payment_detail) p ) n
    on (pd.payment_id = n.payment_id and pd.field_id = n.field_id)
  when matched then 
    update set pd.field_value = n.field_value
  when not matched then 
    insert (payment_id,field_id,field_value)
    values (n.payment_id, n.field_id, n.field_value);
                
end;
/
-- Удаление деталей платежа
create or replace procedure delete_payment_detail (p_payment_id payment.payment_id%type,
                                                   p_delete_detail_ids t_number_array)
is
  v_message varchar2(200 char) := 'Детали платежа удалены по списку id_полей';
  v_current_dtime timestamp := systimestamp;
begin
  if p_payment_id is null then
    dbms_output.put_line ('ID объекта не может быть пустым');
  end if;

  if p_delete_detail_ids is empty then
    dbms_output.put_line ('Коллекция не содержит данных');
  end if;
  
  dbms_output.put_line (v_message || '. ID: ' || p_payment_id);
  dbms_output.put_line (to_char(v_current_dtime,'dd.mm.yyyy hh24:mm:ss.ff'));
  dbms_output.put_line ('Количество полей для удаления: ' || p_delete_detail_ids.count());
 
  --удаление деталей платежа
  delete payment_detail pd
  where pd.payment_id = p_payment_id 
    and pd.field_id in (select value(t) 
                        from table (p_delete_detail_ids) t);
end delete_payment_detail;
/