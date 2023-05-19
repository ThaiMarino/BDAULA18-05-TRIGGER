CREATE TABLE IF NOT EXISTS bdrest.movimento (
	datamovimento DATE NULL, 
    idproduto INT NULL,
    qtde INT NULL,
    FOREIGN KEY(idproduto) REFERENCES bdrest.produto(idproduto)
    ) ENGINE = innodb;

select * from bdrest.movimento;
select * from pedido;


-- 4A. Crie um trigger para atualizar a nova tabela criada na atividade acima,
-- de modo que seja incrementado cada vez que o produto seja pedido. **
-- coloque current_date() na data.
DELIMITER //
CREATE TRIGGER tgprodutoMovimento AFTER INSERT
ON pedido
FOR EACH ROW
BEGIN
	INSERT INTO movimento values(current_date(), NEW.produto_idproduto, NEW.quantidade); 
END //
DELIMITER ;

DROP TRIGGER tgprodutoMovimento;
 
INSERT INTO pedido (idpedido, mesa, produto_idproduto, quantidade)
values(10,18,107,2);


INSERT INTO pedido (idpedido, mesa, produto_idproduto, quantidade)
values(11,11,103,1);

INSERT INTO pedido (idpedido, mesa, produto_idproduto, quantidade)
values(22,2,102,2);

-- 5. Faça outra trigger onde toda vez que um produto for selecionado,
-- verifique se já existem dados para aquele dia e produto. Se existir atualizar
-- a quantidade dos produtos vendidos no dia, se não incluir. Testar.
SELECT idproduto FROM movimento WHERE idproduto = "100";

DELIMITER $
CREATE TRIGGER tgr_verificarDiaProduto after insert
on pedido
for each row
begin
    if((select idproduto from movimento where idproduto = new.produto_idproduto) = new.produto_idproduto and 
    (select datamovimento from movimento where idproduto = new.produto_idproduto) = current_date()) then
			update movimento set qtde = qtde + new.quantidade
			where idproduto = new.produto_idproduto;
	else
		insert into movimento values (current_date(), new.produto_idProduto, new.quantidade);
	end if;
end $
DELIMITER ;
-- PODEMOS USAR DUAS TABELAS NO TRIGGER, ELE NÃO PRECISA DE INNER JOIN
-- QUANDO QUEREMOS COMPARAR VALORES NO TRIGGER OU NO SQL, USAMOS UM *SELECT* COMO UTILIZADO ACIMA, POIS ELE VAI COMPARAR OS VALORES

-- OUTROS EXEMPLOS DE TRIGGER:

DELIMITER $$
CREATE TRIGGER atualizaMovimento
AFTER INSERT ON pedido
FOR EACH ROW
BEGIN
IF (select count(*) from movimento 
	 where idproduto = NEW.produto_idproduto
       and datamovimento = current_date()) > 0 THEN  -- se achar qualquer valor quer dizer que o produto já está cadastrado no dia corrente
    UPDATE movimento
       SET qtde = qtde + NEW.quantidade
	 where idproduto = NEW.produto_idproduto
       and datamovimento = current_date();
ELSE
	INSERT INTO movimento
	VALUES(current_date(),NEW.produto_idproduto,NEW.quantidade);
END IF;
END $$
DELIMITER ;

-- obs:
-- 1- Tabela movimento não pode ter mais de um registro com o mesmo produto na mesma data
-- 2- Necessário dropar trigger anterior 


-- apagar a primeira trigger
 DROP trigger atualizaMovimento;
 select * from pedido;
 select * from movimento; 
 
-- excluir tds pedido do produto 103
delete from pedido where produto_idproduto=103;
-- exclui ultimo registo de movimento 103
delete from movimento where idproduto = 103;


DELIMITER %%
create trigger movimentoPedidoIf after insert
on pedido 
for each row
begin
	if NEW.produto_idproduto = (select movimento.idproduto from movimento where movimento.idproduto = NEW.produto_idproduto) then
		update movimento set movimento.qtde = (movimento.qtde + NEW.quantidade)
        where movimento.idproduto = NEW.produto_idproduto
        and movimento.datamovimento = current_date();
    else
		insert into movimento values
		(now(), NEW.produto_idproduto, NEW.quantidade);
    end if;    
end
%%
DELIMITER ;
 
 SELECT * FROM pedido;
 
 -- 5A. Criar uma trigger para que toda vez que for excluído um pedido, atualize
-- a tabela movimento.
DELIMITER //
CREATE TRIGGER tgr_atualizaExclusao AFTER DELETE 
ON pedido
FOR EACH ROW 
BEGIN
	if OLD.produto_idproduto = (select movimento.idproduto from movimento where movimento.idproduto = OLD.produto_idproduto) THEN
		update movimento set movimento.qtde = (movimento.qtde -old.quantidade)
		WHERE movimento.id_produto = OLD.produto_idproduto
        AND movimento.datamovimento = current_date();
	else
		delete from movimento
        where idproduto = OLD.produto_idproduto;
	end if;
END //
DELIMITER ;

DROP TRIGGER tgr_atualizaExclusao;
SELECT * FROM movimento;

-- PARA DELETAR,TEM QUE DELETAR TODAS AS INFORMAÇÕES DA TABELA
delete from pedido
WHERE pedido.idpedido = 1
AND pedido.mesa = 11
AND PEDIDO.PRODUTO_IDPRODUTO = 105;

-- MESMO TRIGGER USANDO VARIÁVEL VAR E ELSE DIFERENTE 
DELIMITER //
CREATE TRIGGER tgr_atualizaExclusao2 AFTER DELETE 
ON pedido
FOR EACH ROW 
BEGIN
	set @var = (select movimento.idproduto from movimento where movimento.idproduto = OLD.produto_idproduto);
	if var > OLD.quantidade THEN
		update movimento 
        set qtde = (qtde -old.quantidade)
		WHERE id_produto = OLD.produto_idproduto;
	else
		delete from movimento
        where idproduto = OLD.produto_idproduto;
	end if;
END //
DELIMITER ;
DROP TRIGGER tgr_atualizaExclusao2;


-- 6. Criar uma trigger para que toda vez que um produto for excluído da
-- tabela produtos, este mesmo produto seja copiado na tabela exProduto. A
-- tabela exProduto deve ter a mesma estrutura da tabela produto.
SELECT * FROM exproduto;   

DELIMITER $$
CREATE TRIGGER copytoExProduto AFTER DELETE ON pedido
FOR EACH ROW
BEGIN
	INSERT INTO exproduto
	VALUES(OLD.idproduto,old.nomeproduto, old.categoria_idcategoria);
END $$
DELIMITER ;

select * from produto;
select * from exproduto;

