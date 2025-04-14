/*
Автор: Костина Екатерина
Описание скрипта: API для сущностей “Платеж” и “Детали платежа”
*/

-- Создание платежа
declare
	v_message varchar2(200) := 'Платеж создан';
	c_new_status constant number := 0;
begin
	dbms_output.put_line (v_message || '. Статус: ' || c_new_status);
end;
/
-- Перевод платежа в ошибочный статус с описанием причины
declare
	v_message varchar2(200) := 'Сброс платежа в "ошибочный статус" с указанием причины';
	v_reason varchar2(200) := 'недостаточно средств';
	c_error_status constant number := 2;
begin
	dbms_output.put_line (v_message || '. Статус: '|| c_error_status ||'. Причина: ' || v_reason);
end;
/
-- Отмена платежа
declare
	v_message varchar2(200) := 'Отмена платежа с указанием причины';
	v_reason varchar2(200) := 'ошибка пользователя';
	c_cancel_status constant number := 3;
begin
	dbms_output.put_line (v_message || '. Статус: ' || c_cancel_status|| '. Причина: ' || v_reason);
end;
/
-- Завершение платежа
declare
	v_message varchar2(200) := 'Успешное завершение платежа';
	c_success_status constant number := 1;
begin
	dbms_output.put_line (v_message || '. Статус: ' || c_success_status);
end;
/
-- Добавление или обновление данных платежа
declare
	v_message varchar2(200) := 'Данные платежа добавлены или обновлены по списку';
begin
	dbms_output.put_line (v_message || ' id_поля/значение');
end;
/
-- Удаление деталей платежа
declare
	v_message varchar2(200) := 'Детали платежа удалены по списку';
begin
	dbms_output.put_line (v_message || ' id_полей');
end;
/