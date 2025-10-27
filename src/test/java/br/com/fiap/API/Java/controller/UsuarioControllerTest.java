package br.com.fiap.API.Java.controller;

import br.com.fiap.API.Java.dto.UsuarioDTO;
import br.com.fiap.API.Java.entity.Usuario;
import br.com.fiap.API.Java.repository.UsuarioRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class UsuarioControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private ObjectMapper objectMapper;

    @BeforeEach
    void setUp() {
        usuarioRepository.deleteAll();
    }

    @Test
    void testCriarUsuario_Success() throws Exception {
        UsuarioDTO usuarioDTO = new UsuarioDTO();
        usuarioDTO.setNome("João Silva");
        usuarioDTO.setEmail("joao.silva@email.com");
        usuarioDTO.setCpf("12345678901");
        usuarioDTO.setTelefone("(11) 99999-9999");
        usuarioDTO.setEndereco("Rua das Flores, 123");
        usuarioDTO.setSaldo(0.0);
        usuarioDTO.setAtivo(true);

        mockMvc.perform(post("/api/usuarios")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(usuarioDTO)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").exists())
                .andExpect(jsonPath("$.nome").value("João Silva"))
                .andExpect(jsonPath("$.email").value("joao.silva@email.com"));
    }

    @Test
    void testCriarUsuario_EmailDuplicado() throws Exception {
        // Criar primeiro usuário
        Usuario usuario = new Usuario();
        usuario.setNome("Maria Silva");
        usuario.setEmail("maria@email.com");
        usuario.setCpf("11122233344");
        usuarioRepository.save(usuario);

        // Tentar criar outro com mesmo email
        UsuarioDTO usuarioDTO = new UsuarioDTO();
        usuarioDTO.setNome("Pedro Silva");
        usuarioDTO.setEmail("maria@email.com");
        usuarioDTO.setCpf("55566677788");
        usuarioDTO.setAtivo(true);

        mockMvc.perform(post("/api/usuarios")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(usuarioDTO)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void testListarTodosUsuarios() throws Exception {
        Usuario usuario1 = new Usuario("João", "joao@email.com", "11122233344");
        Usuario usuario2 = new Usuario("Maria", "maria@email.com", "22233344455");
        usuarioRepository.save(usuario1);
        usuarioRepository.save(usuario2);

        mockMvc.perform(get("/api/usuarios"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(2));
    }

    @Test
    void testBuscarUsuarioPorId_Success() throws Exception {
        Usuario usuario = new Usuario("João", "joao@email.com", "11122233344");
        usuario = usuarioRepository.save(usuario);

        mockMvc.perform(get("/api/usuarios/" + usuario.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nome").value("João"))
                .andExpect(jsonPath("$.email").value("joao@email.com"));
    }

    @Test
    void testBuscarUsuarioPorId_NotFound() throws Exception {
        mockMvc.perform(get("/api/usuarios/999"))
                .andExpect(status().isNotFound());
    }

    @Test
    void testAtualizarUsuario_Success() throws Exception {
        Usuario usuario = new Usuario("João", "joao@email.com", "11122233344");
        usuario = usuarioRepository.save(usuario);

        UsuarioDTO usuarioDTO = new UsuarioDTO();
        usuarioDTO.setNome("João Silva");
        usuarioDTO.setEmail("joao@email.com");
        usuarioDTO.setCpf("11122233344");
        usuarioDTO.setTelefone("(11) 88888-8888");

        mockMvc.perform(put("/api/usuarios/" + usuario.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(usuarioDTO)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nome").value("João Silva"));
    }

    @Test
    void testDesativarUsuario() throws Exception {
        Usuario usuario = new Usuario("João", "joao@email.com", "11122233344");
        usuario = usuarioRepository.save(usuario);

        mockMvc.perform(delete("/api/usuarios/" + usuario.getId()))
                .andExpect(status().isOk());

        Usuario usuarioAtualizado = usuarioRepository.findById(usuario.getId()).orElse(null);
        assert usuarioAtualizado != null;
        assert !usuarioAtualizado.getAtivo();
    }
}
