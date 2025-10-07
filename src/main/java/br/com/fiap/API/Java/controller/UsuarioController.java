package br.com.fiap.API.Java.controller;

import br.com.fiap.API.Java.dto.UsuarioDTO;
import br.com.fiap.API.Java.entity.Usuario;
import br.com.fiap.API.Java.repository.UsuarioRepository;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/usuarios")
@CrossOrigin(origins = "*")
public class UsuarioController {

    @Autowired
    private UsuarioRepository usuarioRepository;

    // GET - Listar todos os usuários
    @GetMapping
    public ResponseEntity<List<UsuarioDTO>> listarUsuarios() {
        List<Usuario> usuarios = usuarioRepository.findAll();
        List<UsuarioDTO> usuariosDTO = usuarios.stream()
                .map(this::converterParaDTO)
                .collect(Collectors.toList());

        return ResponseEntity.ok(usuariosDTO);
    }

    // GET - Buscar usuário por ID
    @GetMapping("/{id}")
    public ResponseEntity<UsuarioDTO> buscarUsuarioPorId(@PathVariable Long id) {
        Optional<Usuario> usuarioOpt = usuarioRepository.findById(id);

        if (usuarioOpt.isPresent()) {
            UsuarioDTO usuarioDTO = converterParaDTO(usuarioOpt.get());
            return ResponseEntity.ok(usuarioDTO);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // GET - Buscar usuários ativos
    @GetMapping("/ativos")
    public ResponseEntity<List<UsuarioDTO>> buscarUsuariosAtivos() {
        List<Usuario> usuarios = usuarioRepository.findByAtivoTrue();
        List<UsuarioDTO> usuariosDTO = usuarios.stream()
                .map(this::converterParaDTO)
                .collect(Collectors.toList());

        return ResponseEntity.ok(usuariosDTO);
    }

    // GET - Buscar usuários por nome
    @GetMapping("/buscar")
    public ResponseEntity<List<UsuarioDTO>> buscarUsuariosPorNome(@RequestParam String nome) {
        List<Usuario> usuarios = usuarioRepository.findByNomeContainingIgnoreCase(nome);
        List<UsuarioDTO> usuariosDTO = usuarios.stream()
                .map(this::converterParaDTO)
                .collect(Collectors.toList());

        return ResponseEntity.ok(usuariosDTO);
    }

    // GET - Buscar usuário por email
    @GetMapping("/email/{email}")
    public ResponseEntity<UsuarioDTO> buscarUsuarioPorEmail(@PathVariable String email) {
        Optional<Usuario> usuarioOpt = usuarioRepository.findByEmail(email);

        if (usuarioOpt.isPresent()) {
            UsuarioDTO usuarioDTO = converterParaDTO(usuarioOpt.get());
            return ResponseEntity.ok(usuarioDTO);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // POST - Criar novo usuário
    @PostMapping
    public ResponseEntity<?> criarUsuario(@Valid @RequestBody UsuarioDTO usuarioDTO) {
        // Verificar se email já existe
        if (usuarioRepository.existsByEmailAndIdNot(usuarioDTO.getEmail(), null)) {
            return ResponseEntity.badRequest()
                    .body("Erro: Email já cadastrado no sistema.");
        }

        // Verificar se CPF já existe
        if (usuarioRepository.existsByCpfAndIdNot(usuarioDTO.getCpf(), null)) {
            return ResponseEntity.badRequest()
                    .body("Erro: CPF já cadastrado no sistema.");
        }

        Usuario usuario = new Usuario();
        usuario.setNome(usuarioDTO.getNome());
        usuario.setEmail(usuarioDTO.getEmail());
        usuario.setCpf(usuarioDTO.getCpf());
        usuario.setTelefone(usuarioDTO.getTelefone());
        usuario.setEndereco(usuarioDTO.getEndereco());
        usuario.setSaldo(usuarioDTO.getSaldo() != null ? usuarioDTO.getSaldo() : 0.0);
        usuario.setAtivo(usuarioDTO.getAtivo() != null ? usuarioDTO.getAtivo() : true);

        Usuario usuarioSalvo = usuarioRepository.save(usuario);
        UsuarioDTO usuarioRetorno = converterParaDTO(usuarioSalvo);

        return ResponseEntity.status(HttpStatus.CREATED).body(usuarioRetorno);
    }

    // PUT - Atualizar usuário
    @PutMapping("/{id}")
    public ResponseEntity<?> atualizarUsuario(@PathVariable Long id, @Valid @RequestBody UsuarioDTO usuarioDTO) {
        Optional<Usuario> usuarioOpt = usuarioRepository.findById(id);

        if (!usuarioOpt.isPresent()) {
            return ResponseEntity.notFound().build();
        }

        Usuario usuario = usuarioOpt.get();

        // Verificar se email já existe (excluindo o próprio usuário)
        if (usuarioRepository.existsByEmailAndIdNot(usuarioDTO.getEmail(), id)) {
            return ResponseEntity.badRequest()
                    .body("Erro: Email já cadastrado para outro usuário.");
        }

        // Verificar se CPF já existe (excluindo o próprio usuário)
        if (usuarioRepository.existsByCpfAndIdNot(usuarioDTO.getCpf(), id)) {
            return ResponseEntity.badRequest()
                    .body("Erro: CPF já cadastrado para outro usuário.");
        }

        usuario.setNome(usuarioDTO.getNome());
        usuario.setEmail(usuarioDTO.getEmail());
        usuario.setCpf(usuarioDTO.getCpf());
        usuario.setTelefone(usuarioDTO.getTelefone());
        usuario.setEndereco(usuarioDTO.getEndereco());
        usuario.setSaldo(usuarioDTO.getSaldo());
        usuario.setAtivo(usuarioDTO.getAtivo());

        Usuario usuarioAtualizado = usuarioRepository.save(usuario);
        UsuarioDTO usuarioRetorno = converterParaDTO(usuarioAtualizado);

        return ResponseEntity.ok(usuarioRetorno);
    }

    // DELETE - Desativar usuário (soft delete)
    @DeleteMapping("/{id}")
    public ResponseEntity<?> desativarUsuario(@PathVariable Long id) {
        Optional<Usuario> usuarioOpt = usuarioRepository.findById(id);

        if (!usuarioOpt.isPresent()) {
            return ResponseEntity.notFound().build();
        }

        Usuario usuario = usuarioOpt.get();
        usuario.setAtivo(false);
        usuarioRepository.save(usuario);

        return ResponseEntity.ok("Usuário desativado com sucesso.");
    }

    // DELETE - Remover usuário permanentemente
    @DeleteMapping("/{id}/permanente")
    public ResponseEntity<?> removerUsuario(@PathVariable Long id) {
        Optional<Usuario> usuarioOpt = usuarioRepository.findById(id);

        if (!usuarioOpt.isPresent()) {
            return ResponseEntity.notFound().build();
        }

        usuarioRepository.deleteById(id);

        return ResponseEntity.ok("Usuário removido permanentemente.");
    }

    // Método auxiliar para converter Usuario para UsuarioDTO
    private UsuarioDTO converterParaDTO(Usuario usuario) {
        UsuarioDTO dto = new UsuarioDTO();
        dto.setId(usuario.getId());
        dto.setNome(usuario.getNome());
        dto.setEmail(usuario.getEmail());
        dto.setCpf(usuario.getCpf());
        dto.setTelefone(usuario.getTelefone());
        dto.setEndereco(usuario.getEndereco());
        dto.setSaldo(usuario.getSaldo());
        dto.setAtivo(usuario.getAtivo());
        dto.setDataCriacao(usuario.getDataCriacao());
        dto.setDataAtualizacao(usuario.getDataAtualizacao());

        return dto;
    }
}
