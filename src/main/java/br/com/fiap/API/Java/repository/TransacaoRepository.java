package br.com.fiap.API.Java.repository;

import br.com.fiap.API.Java.entity.Transacao;
import br.com.fiap.API.Java.entity.Usuario;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface TransacaoRepository extends JpaRepository<Transacao, Long> {

    // Buscar transações por usuário
    List<Transacao> findByUsuario(Usuario usuario);

    // Buscar transações por usuário com paginação
    Page<Transacao> findByUsuarioOrderByDataTransacaoDesc(Usuario usuario, Pageable pageable);

    // Buscar transações por tipo
    List<Transacao> findByTipo(Transacao.TipoTransacao tipo);

    // Buscar transações por usuário e tipo
    List<Transacao> findByUsuarioAndTipo(Usuario usuario, Transacao.TipoTransacao tipo);

    // Buscar transações por período
    @Query("SELECT t FROM Transacao t WHERE t.dataTransacao BETWEEN :dataInicio AND :dataFim")
    List<Transacao> findTransacoesPorPeriodo(@Param("dataInicio") LocalDateTime dataInicio,
            @Param("dataFim") LocalDateTime dataFim);

    // Buscar transações por usuário e período
    @Query("SELECT t FROM Transacao t WHERE t.usuario = :usuario AND t.dataTransacao BETWEEN :dataInicio AND :dataFim ORDER BY t.dataTransacao DESC")
    List<Transacao> findTransacoesPorUsuarioEPeriodo(@Param("usuario") Usuario usuario,
            @Param("dataInicio") LocalDateTime dataInicio,
            @Param("dataFim") LocalDateTime dataFim);

    // Calcular total de transações por tipo e usuário
    @Query("SELECT COALESCE(SUM(t.valor), 0) FROM Transacao t WHERE t.usuario = :usuario AND t.tipo = :tipo")
    BigDecimal calcularTotalPorTipoEUsuario(@Param("usuario") Usuario usuario,
            @Param("tipo") Transacao.TipoTransacao tipo);

    // Buscar últimas N transações de um usuário
    @Query("SELECT t FROM Transacao t WHERE t.usuario = :usuario ORDER BY t.dataTransacao DESC")
    List<Transacao> findUltimasTransacoes(@Param("usuario") Usuario usuario, Pageable pageable);

    // Buscar transações por valor mínimo
    @Query("SELECT t FROM Transacao t WHERE t.valor >= :valorMinimo")
    List<Transacao> findTransacoesComValorMaiorOuIgual(@Param("valorMinimo") BigDecimal valorMinimo);

    // Contar transações por usuário
    @Query("SELECT COUNT(t) FROM Transacao t WHERE t.usuario = :usuario")
    Long contarTransacoesPorUsuario(@Param("usuario") Usuario usuario);
}
