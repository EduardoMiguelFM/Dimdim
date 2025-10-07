package br.com.fiap.API.Java.controller;

import br.com.fiap.API.Java.dto.TransacaoDTO;
import br.com.fiap.API.Java.entity.Transacao;
import br.com.fiap.API.Java.entity.Usuario;
import br.com.fiap.API.Java.repository.TransacaoRepository;
import br.com.fiap.API.Java.repository.UsuarioRepository;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/transacoes")
@CrossOrigin(origins = "*")
public class TransacaoController {

    @Autowired
    private TransacaoRepository transacaoRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    // GET - Listar todas as transações
    @GetMapping
    public ResponseEntity<List<TransacaoDTO>> listarTransacoes() {
        List<Transacao> transacoes = transacaoRepository.findAll();
        List<TransacaoDTO> transacoesDTO = transacoes.stream()
                .map(this::converterParaDTO)
                .collect(Collectors.toList());

        return ResponseEntity.ok(transacoesDTO);
    }

    // GET - Buscar transação por ID
    @GetMapping("/{id}")
    public ResponseEntity<TransacaoDTO> buscarTransacaoPorId(@PathVariable Long id) {
        Optional<Transacao> transacaoOpt = transacaoRepository.findById(id);

        if (transacaoOpt.isPresent()) {
            TransacaoDTO transacaoDTO = converterParaDTO(transacaoOpt.get());
            return ResponseEntity.ok(transacaoDTO);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // GET - Buscar transações por usuário
    @GetMapping("/usuario/{usuarioId}")
    public ResponseEntity<List<TransacaoDTO>> buscarTransacoesPorUsuario(@PathVariable Long usuarioId) {
        Optional<Usuario> usuarioOpt = usuarioRepository.findById(usuarioId);

        if (!usuarioOpt.isPresent()) {
            return ResponseEntity.notFound().build();
        }

        List<Transacao> transacoes = transacaoRepository.findByUsuario(usuarioOpt.get());
        List<TransacaoDTO> transacoesDTO = transacoes.stream()
                .map(this::converterParaDTO)
                .collect(Collectors.toList());

        return ResponseEntity.ok(transacoesDTO);
    }

    // GET - Buscar transações por usuário com paginação
    @GetMapping("/usuario/{usuarioId}/paginado")
    public ResponseEntity<Page<TransacaoDTO>> buscarTransacoesPorUsuarioPaginado(
            @PathVariable Long usuarioId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        Optional<Usuario> usuarioOpt = usuarioRepository.findById(usuarioId);

        if (!usuarioOpt.isPresent()) {
            return ResponseEntity.notFound().build();
        }

        Pageable pageable = PageRequest.of(page, size);
        Page<Transacao> transacoes = transacaoRepository.findByUsuarioOrderByDataTransacaoDesc(usuarioOpt.get(),
                pageable);

        Page<TransacaoDTO> transacoesDTO = transacoes.map(this::converterParaDTO);

        return ResponseEntity.ok(transacoesDTO);
    }

    // GET - Buscar transações por tipo
    @GetMapping("/tipo/{tipo}")
    public ResponseEntity<List<TransacaoDTO>> buscarTransacoesPorTipo(@PathVariable Transacao.TipoTransacao tipo) {
        List<Transacao> transacoes = transacaoRepository.findByTipo(tipo);
        List<TransacaoDTO> transacoesDTO = transacoes.stream()
                .map(this::converterParaDTO)
                .collect(Collectors.toList());

        return ResponseEntity.ok(transacoesDTO);
    }

    // GET - Buscar últimas N transações de um usuário
    @GetMapping("/usuario/{usuarioId}/ultimas/{quantidade}")
    public ResponseEntity<List<TransacaoDTO>> buscarUltimasTransacoes(
            @PathVariable Long usuarioId,
            @PathVariable int quantidade) {

        Optional<Usuario> usuarioOpt = usuarioRepository.findById(usuarioId);

        if (!usuarioOpt.isPresent()) {
            return ResponseEntity.notFound().build();
        }

        Pageable pageable = PageRequest.of(0, quantidade);
        List<Transacao> transacoes = transacaoRepository.findUltimasTransacoes(usuarioOpt.get(), pageable);

        List<TransacaoDTO> transacoesDTO = transacoes.stream()
                .map(this::converterParaDTO)
                .collect(Collectors.toList());

        return ResponseEntity.ok(transacoesDTO);
    }

    // POST - Criar nova transação
    @PostMapping
    public ResponseEntity<?> criarTransacao(@Valid @RequestBody TransacaoDTO transacaoDTO) {
        Optional<Usuario> usuarioOpt = usuarioRepository.findById(transacaoDTO.getUsuarioId());

        if (!usuarioOpt.isPresent()) {
            return ResponseEntity.badRequest()
                    .body("Erro: Usuário não encontrado.");
        }

        Usuario usuario = usuarioOpt.get();

        // Verificar se usuário está ativo
        if (!usuario.getAtivo()) {
            return ResponseEntity.badRequest()
                    .body("Erro: Usuário inativo não pode realizar transações.");
        }

        // Verificar saldo para saques e transferências
        if (transacaoDTO.getTipo() == Transacao.TipoTransacao.SAQUE || 
            transacaoDTO.getTipo() == Transacao.TipoTransacao.TRANSFERENCIA_ENVIADA) {
            
            if (usuario.getSaldo() < transacaoDTO.getValor().doubleValue()) {
                return ResponseEntity.badRequest()
                        .body("Erro: Saldo insuficiente para realizar a operação.");
            }
        }

        Transacao transacao = new Transacao();
        transacao.setValor(transacaoDTO.getValor());
        transacao.setTipo(transacaoDTO.getTipo());
        transacao.setDescricao(transacaoDTO.getDescricao());
        transacao.setUsuario(usuario);

        Transacao transacaoSalva = transacaoRepository.save(transacao);

        // Atualizar saldo do usuário
        atualizarSaldoUsuario(usuario, transacaoDTO.getTipo(), transacaoDTO.getValor());

        TransacaoDTO transacaoRetorno = converterParaDTO(transacaoSalva);

        return ResponseEntity.status(HttpStatus.CREATED).body(transacaoRetorno);
    }

    // PUT - Atualizar transação
    @PutMapping("/{id}")
    public ResponseEntity<?> atualizarTransacao(@PathVariable Long id, @Valid @RequestBody TransacaoDTO transacaoDTO) {
        Optional<Transacao> transacaoOpt = transacaoRepository.findById(id);

        if (!transacaoOpt.isPresent()) {
            return ResponseEntity.notFound().build();
        }

        Optional<Usuario> usuarioOpt = usuarioRepository.findById(transacaoDTO.getUsuarioId());

        if (!usuarioOpt.isPresent()) {
            return ResponseEntity.badRequest()
                    .body("Erro: Usuário não encontrado.");
        }

        Transacao transacao = transacaoOpt.get();
        Usuario usuario = usuarioOpt.get();

        // Reverter saldo anterior
        reverterSaldoUsuario(usuario, transacao.getTipo(), transacao.getValor());

        // Aplicar nova transação
        if (transacaoDTO.getTipo() == Transacao.TipoTransacao.SAQUE || 
            transacaoDTO.getTipo() == Transacao.TipoTransacao.TRANSFERENCIA_ENVIADA) {
            
            if (usuario.getSaldo() < transacaoDTO.getValor().doubleValue()) {
                return ResponseEntity.badRequest()
                        .body("Erro: Saldo insuficiente para realizar a operação.");
            }
        }

        transacao.setValor(transacaoDTO.getValor());
        transacao.setTipo(transacaoDTO.getTipo());
        transacao.setDescricao(transacaoDTO.getDescricao());
        transacao.setUsuario(usuario);

        Transacao transacaoAtualizada = transacaoRepository.save(transacao);

        // Atualizar saldo do usuário
        atualizarSaldoUsuario(usuario, transacaoDTO.getTipo(), transacaoDTO.getValor());

        TransacaoDTO transacaoRetorno = converterParaDTO(transacaoAtualizada);

        return ResponseEntity.ok(transacaoRetorno);
    }

    // DELETE - Remover transação
    @DeleteMapping("/{id}")
    public ResponseEntity<?> removerTransacao(@PathVariable Long id) {
        Optional<Transacao> transacaoOpt = transacaoRepository.findById(id);

        if (!transacaoOpt.isPresent()) {
            return ResponseEntity.notFound().build();
        }

        Transacao transacao = transacaoOpt.get();
        Usuario usuario = transacao.getUsuario();

        // Reverter saldo do usuário
        reverterSaldoUsuario(usuario, transacao.getTipo(), transacao.getValor());

        transacaoRepository.deleteById(id);

        return ResponseEntity.ok("Transação removida com sucesso.");
    }

    // Método auxiliar para atualizar saldo do usuário
    private void atualizarSaldoUsuario(Usuario usuario, Transacao.TipoTransacao tipo, BigDecimal valor) {
        Double saldoAtual = usuario.getSaldo();
        Double novoSaldo = saldoAtual;

        switch (tipo) {
            case DEPOSITO:
            case TRANSFERENCIA_RECEBIDA:
            case RECEBIMENTO:
                novoSaldo = saldoAtual + valor.doubleValue();
                break;
            case SAQUE:
            case TRANSFERENCIA_ENVIADA:
            case PAGAMENTO:
                novoSaldo = saldoAtual - valor.doubleValue();
                break;
        }

        usuario.setSaldo(novoSaldo);
        usuarioRepository.save(usuario);
    }

    // Método auxiliar para reverter saldo do usuário
    private void reverterSaldoUsuario(Usuario usuario, Transacao.TipoTransacao tipo, BigDecimal valor) {
        Double saldoAtual = usuario.getSaldo();
        Double novoSaldo = saldoAtual;

        switch (tipo) {
            case DEPOSITO:
            case TRANSFERENCIA_RECEBIDA:
            case RECEBIMENTO:
                novoSaldo = saldoAtual - valor.doubleValue();
                break;
            case SAQUE:
            case TRANSFERENCIA_ENVIADA:
            case PAGAMENTO:
                novoSaldo = saldoAtual + valor.doubleValue();
                break;
        }

        usuario.setSaldo(novoSaldo);
        usuarioRepository.save(usuario);
    }

    // Método auxiliar para converter Transacao para TransacaoDTO
    private TransacaoDTO converterParaDTO(Transacao transacao) {
        TransacaoDTO dto = new TransacaoDTO();
        dto.setId(transacao.getId());
        dto.setValor(transacao.getValor());
        dto.setTipo(transacao.getTipo());
        dto.setDescricao(transacao.getDescricao());
        dto.setUsuarioId(transacao.getUsuario().getId());
        dto.setNomeUsuario(transacao.getUsuario().getNome());
        dto.setDataTransacao(transacao.getDataTransacao());
        dto.setDataCriacao(transacao.getDataCriacao());
        dto.setDataAtualizacao(transacao.getDataAtualizacao());

        return dto;
    }
}
