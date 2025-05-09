/*
Автор: Костина Екатерина
Описание скрипта: API для сущностей “Платеж” и “Детали платежа”
*/

-- Создание платежа
declare
  v_payment_id  payment.payment_id%type;
  v_message varchar2(200 char) := 'Платеж создан';
  c_new_status constant payment.status%type := 0;
  v_current_dtime date := sysdate;
  v_payment_detail t_payment_detail_array:= t_payment_detail_array(t_payment_detail(1,'Тестовый софт'),
                                                                   t_payment_detail(2,'66.250.68.32'),
                                                                   t_payment_detail(3,'Создание'));
begin
  
  if v_payment_detail is not empty then
  
    for i in v_payment_detail.first..v_payment_detail.last loop 
	
      if (v_payment_detail(i).field_id is null) then
        dbms_output.put_line ('ID поля не может быть пустым');
      end if;
	
      if (v_payment_detail(i).field_value is null) then
        dbms_output.put_line ('Значение в поле не может быть пустым');
      end if;
		 
    end loop;
   
  else
    dbms_output.put_line ('Коллекция не содержит данных');
  end if;
  
  dbms_output.put_line (v_message || '. Статус: ' || c_new_status || '. ID: ' || v_payment_id);
  dbms_output.put_line (to_char(v_current_dtime,'dd.mm.yyyy hh24:mm:ss'));
end;
/
-- Перевод платежа в ошибочный статус с описанием причины
declare
  v_payment_id  payment.payment_id%type := 1;
  v_message varchar2(200 char) := 'Сброс платежа в "ошибочный статус" с указанием причины';
  v_reason payment.status_change_reason%type := 'недостаточно средств';
  c_error_status constant payment.status%type := 2;
  v_current_dtime date := sysdate;
begin
  if v_payment_id is null then
    dbms_output.put_line ('ID объекта не может быть пустым');
  end if;
  
  if v_reason is null then
    dbms_output.put_line ('Причина не может быть пустой');
  end if;
  
  dbms_output.put_line (v_message || '. Статус: '|| c_error_status ||'. Причина: ' || v_reason || '. ID: ' || v_payment_id);
  dbms_output.put_line (to_char(v_current_dtime,'dd.mm.yyyy hh24:mm:ss'));
end;
/
-- Отмена платежа
declare
  v_payment_id  payment.payment_id%type;
  v_message varchar2(200 char) := 'Отмена платежа с указанием причины';
  v_reason payment.status_change_reason%type := 'ошибка пользователя';
  c_cancel_status constant payment.status%type := 3;
  v_current_dtime date := sysdate;
begin
  if v_payment_id is null then
    dbms_output.put_line ('ID объекта не может быть пустым');
  end if;
  
  if v_reason is null then
    dbms_output.put_line ('Причина не может быть пустой');
  end if;
  
  dbms_output.put_line (v_message || '. Статус: ' || c_cancel_status|| '. Причина: ' || v_reason || '. ID: ' || v_payment_id);
  dbms_output.put_line (to_char(v_current_dtime,'dd.mm.yyyy hh24:mm:ss'));
end;
/
-- Завершение платежа
declare
  v_payment_id  payment.payment_id%type;
  v_message varchar2(200 char) := 'Успешное завершение платежа';
  c_success_status constant payment.status%type := 1;
  v_current_dtime date := sysdate;
begin
  if v_payment_id is null then
    dbms_output.put_line ('ID объекта не может быть пустым');
  end if;
  
  dbms_output.put_line (v_message || '. Статус: ' || c_success_status);
  dbms_output.put_line (to_char(v_current_dtime,'dd.mm.yyyy hh24:mm:ss'));
end;
/
-- Добавление или обновление данных платежа
declare
  v_payment_id  payment.payment_id%type := 1;
  v_message varchar2(200 char) := 'Данные платежа добавлены или обновлены по списку id_поля/значение';
  v_current_dtime timestamp := systimestamp;
  v_payment_detail t_payment_detail_array:= t_payment_detail_array(t_payment_detail(2,'66.250.68.32'),
                                                                   t_payment_detail(3,'Обновление'));
begin
  if v_payment_id is null then
    dbms_output.put_line ('ID объекта не может быть пустым');
  end if;
  
  if v_payment_detail is not empty then
  
    for i in v_payment_detail.first..v_payment_detail.last loop 
	
      if (v_payment_detail(i).field_id is null) then
        dbms_output.put_line ('ID поля не может быть пустым');
      end if;
	
      if (v_payment_detail(i).field_value is null) then
        dbms_output.put_line ('Значение в поле не может быть пустым');
      end if;
		 
    end loop;
   
  else
    dbms_output.put_line ('Коллекция не содержит данных');
  end if;
  
  dbms_output.put_line (v_message || '. ID: ' || v_payment_id);
  dbms_output.put_line (to_char(v_current_dtime,'dd.mm.yyyy hh24:mm:ss.ff'));
end;
/
-- Удаление деталей платежа
declare
  v_payment_id  payment.payment_id%type := 1;
  v_message varchar2(200 char) := 'Детали платежа удалены по списку id_полей';
  v_current_dtime timestamp := systimestamp;
  v_delete_detail_ids t_number_array:= t_number_array(1,3);
begin
  if v_payment_id is null then
    dbms_output.put_line ('ID объекта не может быть пустым');
  end if;

  if v_delete_detail_ids is empty then
    dbms_output.put_line ('Коллекция не содержит данных');
  end if;
  
  dbms_output.put_line (v_message || '. ID: ' || v_payment_id);
  dbms_output.put_line (to_char(v_current_dtime,'dd.mm.yyyy hh24:mm:ss.ff'));
  dbms_output.put_line ('Количество полей для удаления: ' || v_delete_detail_ids.count());
end;
/