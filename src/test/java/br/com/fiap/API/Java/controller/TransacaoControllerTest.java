package br.com.fiap.API.Java.controller;

import br.com.fiap.API.Java.dto.TransacaoDTO;
import br.com.fiap.API.Java.entity.Transacao;
import br.com.fiap.API.Java.entity.Usuario;
import br.com.fiap.API.Java.repository.TransacaoRepository;
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

import java.math.BigDecimal;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class TransacaoControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private TransacaoRepository transacaoRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private ObjectMapper objectMapper;

    private Usuario usuario;

    @BeforeEach
    void setUp() {
        transacaoRepository.deleteAll();
        usuarioRepository.deleteAll();

        usuario = new Usuario("João Silva", "joao@email.com", "12345678901");
        usuario.setSaldo(1000.0);
        usuario = usuarioRepository.save(usuario);
    }

    @Test
    void testCriarDeposito_Success() throws Exception {
        TransacaoDTO transacaoDTO = new TransacaoDTO();
        transacaoDTO.setValor(BigDecimal.valueOf(500.0));
        transacaoDTO.setTipo(Transacao.TipoTransacao.DEPOSITO);
        transacaoDTO.setDescricao("Depósito inicial");
        transacaoDTO.setUsuarioId(usuario.getId());

        mockMvc.perform(post("/api/transacoes")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(transacaoDTO)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").exists())
                .andExpect(jsonPath("$.tipo").value("DEPOSITO"));
    }

    @Test
    void testCriarSaque_Success() throws Exception {
        TransacaoDTO transacaoDTO = new TransacaoDTO();
        transacaoDTO.setValor(BigDecimal.valueOf(100.0));
        transacaoDTO.setTipo(Transacao.TipoTransacao.SAQUE);
        transacaoDTO.setDescricao("Saque de emergência");
        transacaoDTO.setUsuarioId(usuario.getId());

        mockMvc.perform(post("/api/transacoes")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(transacaoDTO)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.tipo").value("SAQUE"));
    }

    @Test
    void testCriarSaque_SaldoInsuficiente() throws Exception {
        TransacaoDTO transacaoDTO = new TransacaoDTO();
        transacaoDTO.setValor(BigDecimal.valueOf(2000.0)); // Valor maior que o saldo
        transacaoDTO.setTipo(Transacao.TipoTransacao.SAQUE);
        transacaoDTO.setDescricao("Saque com saldo insuficiente");
        transacaoDTO.setUsuarioId(usuario.getId());

        mockMvc.perform(post("/api/transacoes")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(transacaoDTO)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void testListarTodasTransacoes() throws Exception {
        Transacao transacao1 = new Transacao(BigDecimal.valueOf(500.0), Transacao.TipoTransacao.DEPOSITO, "Depósito 1",
                usuario);
        Transacao transacao2 = new Transacao(BigDecimal.valueOf(100.0), Transacao.TipoTransacao.SAQUE, "Saque 1",
                usuario);
        transacaoRepository.save(transacao1);
        transacaoRepository.save(transacao2);

        mockMvc.perform(get("/api/transacoes"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(2));
    }

    @Test
    void testBuscarTransacoesPorUsuario() throws Exception {
        Transacao transacao = new Transacao(BigDecimal.valueOf(500.0), Transacao.TipoTransacao.DEPOSITO, "Depósito",
                usuario);
        transacaoRepository.save(transacao);

        mockMvc.perform(get("/api/transacoes/usuario/" + usuario.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1));
    }

    @Test
    void testBuscarTransacaoPorId_Success() throws Exception {
        Transacao transacao = new Transacao(BigDecimal.valueOf(500.0), Transacao.TipoTransacao.DEPOSITO, "Depósito",
                usuario);
        transacao = transacaoRepository.save(transacao);

        mockMvc.perform(get("/api/transacoes/" + transacao.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(transacao.getId()));
    }

    @Test
    void testBuscarTransacaoPorId_NotFound() throws Exception {
        mockMvc.perform(get("/api/transacoes/999"))
                .andExpect(status().isNotFound());
    }

    @Test
    void testRemoverTransacao() throws Exception {
        Transacao transacao = new Transacao(BigDecimal.valueOf(100.0), Transacao.TipoTransacao.SAQUE, "Saque", usuario);
        transacao = transacaoRepository.save(transacao);

        mockMvc.perform(delete("/api/transacoes/" + transacao.getId()))
                .andExpect(status().isOk());
    }
}
