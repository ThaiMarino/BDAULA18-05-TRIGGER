-- 1 Crie um trigger para baixar o estoque de um PRODUTO
-- quando ele for vendido
-- teste para inserção de produto
-- INSERT INTO EX2_PEDIDO VALUES (7,1,'2012-04-01', '00001', 400.00);
DELIMITER //
CREATE TRIGGER baixar_estoque after insert 
ON EX2_ITEMPEDIDO
FOR EACH ROW
BEGIN
	UPDATE EX2_PRODUTO
    SET quantidade = quantidade - NEW.quantidade
    WHERE codproduto = NEW.codproduto;
END//

drop trigger baixar_estoque;
delete from ex2_pedido
INSERT INTO EX2_PEDIDO VALUES (7, 1, '2012-04-01', '00001', 400.00); 
INSERT INTO EX2_ITEMPEDIDO VALUES (7, 1, 10.90, 1, 1); 
select * from ex2_produto;

SELECT * FROM EX2_ITEMPEDIDO;
SELECT * FROM EX2_PEDIDO;

-- DELETE FROM EX2_PEDIDO WHERE codpedido = "7";





-- 2 Crie um trigger para criar um log dos CLIENTES inseridos
-- CRIANDO UM NOVO CLIENTE 
-- INSERT INTO EX2_CLIENTE  VALUES (8, 'José Adolfo', '1998-11-05', '55555555591'); 

DELIMITER //
CREATE TRIGGER log_cliente after insert
on ex2_cliente
for each row
begin
	insert into ex2_log(data, descricao)
    values (curdate(), new.nome);
END//

INSERT INTO EX2_CLIENTE  VALUES (8, 'José Adolfo', '1998-11-05', '55555555591'); 
SELECT * FROM EX2_LOG
SELECT * FROM EX2_cliente

-- 3) Crie um TRIGGER para criar um log dos PRODUTOS atualizados.
-- ATUALIZANDO UM PRODUTO 
-- UPDATE EX2_PRODUTO SET DESCRICAO=’MOUSEPAD’ WHERE CODPRODUTO =1; 
-- UPDATE EX2_PRODUTO SET quantidade = 20 WHERE CODPRODUTO = 1; 
-- ignorar
DELIMITER $$
CREATE TRIGGER produtos_Atualizados
AFTER UPDATE ON EX2_PRODUTO
FOR EACH ROW
BEGIN
    -- Verifica se houve alteração na descrição do produto
    IF 
    NEW.DESCRICAO <> OLD.DESCRICAO THEN
        INSERT INTO log_produtos_atualizados (CODPRODUTO, ATRIBUTO, VALOR_ANTIGO, VALOR_NOVO, DATA_ATUALIZACAO)
        VALUES (NEW.CODPRODUTO, 'DESCRICAO', OLD.DESCRICAO, NEW.DESCRICAO, NEW.current_date());
    -- Verifica se houve alteração na quantidade do produto
    ELSE IF 
    NEW.QUANTIDADE <> OLD.QUANTIDADE THEN
        INSERT INTO log_produtos_atualizados (CODPRODUTO, ATRIBUTO, VALOR_ANTIGO, VALOR_NOVO, DATA_ATUALIZACAO)
        VALUES (NEW.CODPRODUTO, 'QUANTIDADE', OLD.QUANTIDADE, NEW.QUANTIDADE, NOW());
    END IF;
END $$
DELIMITER ;


-- ex3 Correto e menor
delimiter //
CREATE TRIGGER log_produto AFTER UPDATE
ON ex2_produto
FOR EACH ROW
BEGIN
	insert into ex2_log(data, descricao)
    values (curdate(), new.codproduto);
END //
DELIMITER ;

UPDATE EX2_PRODUTO SET DESCRICAO='MOUSEPAD' WHERE CODPRODUTO =1; 
UPDATE EX2_PRODUTO SET quantidade = 20 WHERE CODPRODUTO = 1; 

select * from ex2_produto;
select * from ex2_log;


-- 4) Crie um trigger para criar um log quando não existir a quantidade do EX2_ITEMPEDIDO em estoque:
DELIMITER $$
CREATE TRIGGER log_itemPedido AFTER INSERT
ON ex2_itempedido
FOR EACH ROW
BEGIN
	declare descricaoLog varchar(100);
		set descricaoLog = concat('Não há produtos suficientes para esta ordem.');
  
    IF quantidade.ex2_produto < NEW.quantidade.ex2_itempedido THEN
		insert into ex2_log(data, descricao)
		values (curdate(), descricaoLog);
	end if;
    
END $$
DELIMITER ;

DROP TRIGGER log_itemPedido;
INSERT INTO EX2_PEDIDO VALUES (7,1,'2012-04-01', '00001', 400.00);
DELETE FROM EX2_PEDIDO WHERE codpedido = "7";
select * FROM ex2_log;
select * from ex2_produto;

-- Código do Rafael
DELIMITER %%
create trigger criarLogProduto before insert
on ex2_itempedido 
for each row
begin
	if (select ex2_produto.quantidade from ex2_produto where ex2_produto.codproduto = NEW.codproduto) - new.quantidade >= 0 then
		insert into ex2_log(data, descricao)
        values (current_date(), 'Adicionado');
	else 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Estoque vai ficar negativo';
    end if;    
end
%%
DELIMITER ;
drop trigger criarLogProduto;

INSERT INTO EX2_PEDIDO VALUES (7, 1, '2012-04-01', '00001', 400.00);
INSERT INTO EX2_ITEMPEDIDO VALUES (7, 1, 10.90, 1, 1); 
INSERT INTO EX2_ITEMPEDIDO VALUES (7, 3, 389.10, 3, 3); 
INSERT INTO EX2_ITEMPEDIDO VALUES (6, 3, 389.10, 11, 3);
INSERT INTO EX2_ITEMPEDIDO VALUES (6, 4, 389.10, 8, 3); 

select * from EX2_ITEMPEDIDO;
select * from EX2_LOG;
select * from ex2_produto;





-- 5) Crie um trigger para criar uma requisição de REQUISICAO_COMPRA quando o estoque atingir 50% da venda mensal




-- 6) Crie um trigger para criar um log quando um ITEMPEDIDO for removido





-- 7) Crie um trigger para criar um log quando o valor total do pedido for maior que R$1000


