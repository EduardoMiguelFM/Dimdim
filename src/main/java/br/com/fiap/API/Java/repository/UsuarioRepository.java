package br.com.fiap.API.Java.repository;

import br.com.fiap.API.Java.entity.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    // Buscar usuário por email
    Optional<Usuario> findByEmail(String email);

    // Buscar usuário por CPF
    Optional<Usuario> findByCpf(String cpf);

    // Buscar usuários ativos
    List<Usuario> findByAtivoTrue();

    // Buscar usuários por nome (case insensitive)
    List<Usuario> findByNomeContainingIgnoreCase(String nome);

    // Buscar usuários com saldo maior que um valor específico
    @Query("SELECT u FROM Usuario u WHERE u.saldo > :saldo AND u.ativo = true")
    List<Usuario> findUsuariosComSaldoMaiorQue(@Param("saldo") Double saldo);

    // Verificar se email já existe (excluindo o próprio usuário na atualização)
    @Query("SELECT COUNT(u) > 0 FROM Usuario u WHERE u.email = :email AND (:id IS NULL OR u.id != :id)")
    boolean existsByEmailAndIdNot(@Param("email") String email, @Param("id") Long id);

    // Verificar se CPF já existe (excluindo o próprio usuário na atualização)
    @Query("SELECT COUNT(u) > 0 FROM Usuario u WHERE u.cpf = :cpf AND (:id IS NULL OR u.id != :id)")
    boolean existsByCpfAndIdNot(@Param("cpf") String cpf, @Param("id") Long id);
}
