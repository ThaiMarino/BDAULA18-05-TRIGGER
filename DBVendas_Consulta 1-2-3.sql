#1
DELIMITER %%
create trigger baixarEstoque after insert
on ex2_itempedido 
for each row
begin
	update ex2_produto produto 
    set produto.quantidade = (produto.quantidade - NEW.quantidade)
    where produto.codproduto = NEW.codproduto;
end
%%
DELIMITER ;

INSERT INTO EX2_PEDIDO VALUES (7, 1, '2012-04-01', '00001', 400.00);
INSERT INTO EX2_ITEMPEDIDO VALUES (7, 1, 10.90, 1, 1);

select * from  EX2_ITEMPEDIDO;
select * from  EX2_produto;
 

-- ------------------------------------------------------------------------------------------------

drop trigger baixarEstoque;

DELIMITER $
CREATE TRIGGER atualiza_estoque after insert
on ex2_itempedido
for each row
begin
   if(select count(*) from ex2_produto
   where codproduto = NEW.codproduto) > 0 then
   update ex2_produto
		set quantidade = quantidade - new.quantidade
	where codproduto = new.codproduto;
   end if;
end $
DELIMITER 

INSERT INTO EX2_ITEMPEDIDO VALUES (7, 2, 389.10, 1, 3); 

select * from  EX2_ITEMPEDIDO;
select * from  EX2_produto;

-- ------------------------------------------------------------------------------------------------
#2
DELIMITER $$
CREATE TRIGGER criarLogCliente 
AFTER INSERT ON EX2_CLIENTE
FOR EACH ROW 
BEGIN
	insert into EX2_LOG (data, descricao) 
    values (current_date(), concat('Cliente: ', new.codcliente, 'adicionado com sucesso'));
END $$
DELIMITER ;


-- ------------------------------------------------------------------------------------------------

DELIMITER %%
create trigger logCliente after insert
on ex2_cliente 
for each row
begin
	declare descricaoLog varchar(100);
    set descricaoLog = concat('Foi adicionado o cliente com o id: ', NEW.codcliente, ' e Nome: ', NEW.nome);
    
	insert into ex2_log(data, descricao)
    values (current_date(), descricaoLog);
end
%%
DELIMITER ;

INSERT INTO EX2_CLIENTE  VALUES (8, 'José Adolfo', '1998-11-05', '55555555591'); 

select * from ex2_log;

-- ------------------------------------------------------------------------------------------------
#3
delimiter //
create trigger log_produto after update
on ex2_produto
for each row
begin
	insert into ex2_log (data, descricao) 
    values (current_date(), concat('produto atualizado cod: ', new.codproduto)); 
end //
delimiter ;

UPDATE EX2_PRODUTO SET DESCRICAO="MOUSEPAD" WHERE CODPRODUTO =1; 
select * from ex2_produto;
select * from ex2_log;

-- ------------------------------------------------------------------------------------------------
drop trigger log_produto;
 
delimiter //

create trigger tr_registrar_produto_atualizado
after update on ex2_produto
for each row
begin 
    if new.descricao != old.descricao then
        insert into ex2_log (data, descricao)
        values (current_date, concat('descrição do produto atualizada - cod.: ', new.codproduto, ', nova descrição: ', new.descricao));
    end if;

    if new.quantidade != old.quantidade then
        insert into ex2_log (data, descricao)
        values (current_date, concat('quantidade do produto atualizada - cod.: ', new.codproduto, ', nova quantidade: ', new.quantidade));
    end if;
end//

delimiter ;

UPDATE EX2_PRODUTO SET quantidade = 20 WHERE CODPRODUTO = 1; 
select * from ex2_produto;
select * from ex2_log;

INSERT INTO EX2_ITEMPEDIDO VALUES (7, 3, 389.10, 5, 1); 
select * from ex2_itempedido;
select * from ex2_produto;
select * from ex2_log;
