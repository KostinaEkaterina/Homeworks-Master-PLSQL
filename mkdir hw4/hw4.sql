/*
Автор: Костина Екатерина
Описание скрипта: API для сущностей “Платеж” и “Детали платежа”
*/

-- Создание платежа
declare
  v_message varchar2(200 char) := 'Платеж создан';
  c_new_status constant number(10) := 0;
  v_current_dtime date := sysdate;
begin
  dbms_output.put_line (v_message || '. Статус: ' || c_new_status);
  dbms_output.put_line (to_char(v_current_dtime,'dd.mm.yyyy hh24:mm:ss'));
end;
/
-- Перевод платежа в ошибочный статус с описанием причины
declare
  v_message varchar2(200 char) := 'Сброс платежа в "ошибочный статус" с указанием причины';
  v_reason varchar2(200 char) := 'недостаточно средств';
  c_error_status constant number(10) := 2;
  v_current_dtime date := sysdate;
begin
  dbms_output.put_line (v_message || '. Статус: '|| c_error_status ||'. Причина: ' || v_reason);
  dbms_output.put_line (to_char(v_current_dtime,'dd.mm.yyyy hh24:mm:ss'));
end;
/
-- Отмена платежа
declare
  v_message varchar2(200 char) := 'Отмена платежа с указанием причины';
  v_reason varchar2(200 char) := 'ошибка пользователя';
  c_cancel_status constant number(10) := 3;
  v_current_dtime date := sysdate;
begin
  dbms_output.put_line (v_message || '. Статус: ' || c_cancel_status|| '. Причина: ' || v_reason);
  dbms_output.put_line (to_char(v_current_dtime,'dd.mm.yyyy hh24:mm:ss'));
end;
/
-- Завершение платежа
declare
  v_message varchar2(200 char) := 'Успешное завершение платежа';
  c_success_status constant number(10) := 1;
  v_current_dtime date := sysdate;
begin
  dbms_output.put_line (v_message || '. Статус: ' || c_success_status);
  dbms_output.put_line (to_char(v_current_dtime,'dd.mm.yyyy hh24:mm:ss'));
end;
/
-- Добавление или обновление данных платежа
declare
  v_message varchar2(200 char) := 'Данные платежа добавлены или обновлены по списку id_поля/значение';
  v_current_dtime timestamp := systimestamp;
begin
  dbms_output.put_line (v_message);
  dbms_output.put_line (to_char(v_current_dtime,'dd.mm.yyyy hh24:mm:ss.ff'));
end;
/
-- Удаление деталей платежа
declare
  v_message varchar2(200 char) := 'Детали платежа удалены по списку id_полей';
  v_current_dtime timestamp := systimestamp;
begin
  dbms_output.put_line (v_message);
  dbms_output.put_line (to_char(v_current_dtime,'dd.mm.yyyy hh24:mm:ss.ff'));
end;
/