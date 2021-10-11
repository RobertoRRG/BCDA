/*
 * Roberto Ríos Guzmán
 * Jose Hernandez Segura
 * Miguel Fernandez Romojaro
*/
pragma solidity ^0.8.7;
/*
 *  El contrato Asignatura que representa una asignatura de la carrera.
 *
 * Version 2021 - Clase de Teoria
 */
contract Asignatura {
    
    /// Version 2021 - Teoria
    uint public version = 2021;
    /// nombre de la asignatura 
    string public nombre;
    /// nombre del curso académico
    string public curso;
    /// dirección del usuario que desplegó el contrato
    address public owner;
    /// dirección del coordinador de la asignatura
    address public coordinador;
    /// indica si la asignatura se ha cerrado
    bool public cerrada = false;
    /// direcciones de profesores
    address[] public profesores;
    /// mapa con las direcciones de usuario de profesor y nombres
    mapping(address=>string) public datosProfesor;
    /// Datos de un alumno.
    struct DatosAlumno {
        string nombre;
        string DNI;
        string email;
    }
    /// Acceder a los datos de un alumno dada su direccion.
    mapping (address => DatosAlumno) public datosAlumno;
    /// direcciones de alumnos
    address[] public matriculas;
    /// Evaluacion
    struct evaluacion {
        string nombre;
        uint fecha;
        uint nota;
    }
    /// arrays de evaluaciones de Asignatura
    evaluacion[] public evaluaciones;
    ///enumeracion con el tipo de nota
    enum tipoNota{NP,normal,MH}
    ///struct con le tipo de nota y la puntuación
    struct Nota {
        tipoNota tipo;
        uint calificacion;
    }
    ///error personalizado DNI Existente
    error DNIrepetido(string msg);
    /// calificaciones de los alumnos
    mapping (address => mapping(uint => Nota)) public calificaciones;
    /*
     * constructor
     * 
     * @param: _nombre nombre de la Asignatura
     * @param: _curso académico de la asignatura
    */
    constructor(string memory _nombre, string memory _curso){
        //Comprobar variable _nombre está vacía
        bytes memory bn = bytes(_nombre);
        require(bn.length != 0, "El nombre de la asignatura no puede ser vacio");
        //Comprobar variable _curso está vacía
        bytes memory bc = bytes(_curso);
        require(bc.length != 0, "El curso academico de la asignatura no puede ser vacio");

        nombre = _nombre;
        curso = _curso;
        owner = msg.sender;
    }
    /*
     * setCoordinador: asigna dirección del coordinador de la asignatura.
     * 
     * @param: _coordinador permite asignar un valor a la dirección del coordinador
    */
    function setCoordinador(address _coordinador) soloOwner soloAbierta public{
        coordinador = _coordinador;
    }
    /**
     *cerrar: permite cerrar una asignatura. 
     *
    */
    function cerrar() soloCoordinador public{
        cerrada = true;
    }
    /**
     *permite añadir un profesor a la asignatura. 
     *
     *@param direccionProfesor: contiene la direccion del profesor
     *@param nombreProfesor: contiene el nombre del profesor.
     */
    function addProfesor(address direccionProfesor, string memory nombreProfesor) soloOwner soloAbierta public{
        //Comprobar variable nombreProfesor está vacía
        bytes memory bn = bytes(nombreProfesor);
        require(bn.length != 0, "El nombre del profesor no puede estar vacio");
        //Comprobar que no exista está dirección
        bytes memory bd = bytes(datosProfesor[direccionProfesor]);
        require(bd.length == 0, "No se puede duplicar");
        //Añadir direccion a array de direcciones de usuario de profesor
        profesores.push(direccionProfesor);
        //Añadir direccion y nombre de profesor
        datosProfesor[direccionProfesor] = nombreProfesor;
    }
    /**
     * El numero de profesores creados.
     *
     * @return El numero de profesores creados.
     */
    function profesoresLength() public view returns(uint) {
        return profesores.length;
    }
    /**
     * Se matricula un usuario
     * 
     */
     function automatricula(string memory _nombre,string memory _DNI, string memory _email) noMatriculados soloAbierta public{
        //Comprobar variable nombre está vacía
        bytes memory bn = bytes(_nombre);
        require(bn.length != 0, "El nombre no puede estar vacio");
        //Comprobar variable DNI está vacía
        bytes memory bd = bytes(_DNI);
        require(bd.length != 0, "El DNI no puede estar vacio");
        //Comprobar que no exista este DNI
        bytes memory bduplicado = bytes(datosAlumno[msg.sender].DNI);
        if (bduplicado.length != 0) 
            revert DNIrepetido("No se puede duplicar alumno");
        /// guardamos en el mapa de usuarios
        DatosAlumno memory datos = DatosAlumno(_nombre,_DNI, _email);
        datosAlumno[msg.sender] = datos;
        matriculas.push(msg.sender);
     }
    /**
     * El numero de alumnos creados.
     *
     * @return El numero de alumnos creados.
     */
    function matriculaLength() public view returns(uint) {
        return matriculas.length;
    }
    /**
     * Permite a un alumno obtener sus propios datos.
     * 
     * @return _nombre El nombre del alumno que invoca el metodo.
     * @return _DNI el dni del alumno que invoca el metodo
     * @return _email  El email del alumno que invoca el metodo.
     */
    function quienSoy() soloMatriculados public view returns (string memory _nombre, string memory _DNI,string memory _email) {
        DatosAlumno memory datos = datosAlumno[msg.sender];
        _nombre = datos.nombre;
        _email = datos.email;
        _DNI = datos.DNI;
    }
    /**
     * crea una evaluacion 
     * 
     * @param _nombre nombre de la evaluacion
     * @param _fecha fecha de la evaluacion
     * @param _nota nota que proporciona a la nota final
     */
     function creaEvaluacion(string memory _nombre, uint _fecha, uint  _nota) soloCoordinador soloAbierta public returns(uint){
         evaluaciones.push(evaluacion(_nombre,_fecha,_nota));
         return evaluaciones.length - 1;
     }
    /**
     * El numero de evaluaciones creados.
     *
     * @return El numero de evaluaciones creados.
     */
    function evaluacionesLength() public view returns(uint) {
        return evaluaciones.length;
    }
    /**
     * Guardar las notas en un mapping doble (un mapping de un papping) llamado calificaciones. 
     * El primer mapping tendrá como clave la direccion de un alumno, y el valor asociado será un segundo mapping. 
     * Este segundo mapping tendrá como clave el índice de la evaluación, y devolverá la nota obtenida por el alumno en la evaluación. 
     * 
     * @param _direccionAlumno dirección del alumno
     * @param _indiceEvaluacion indice que oontiene la evaluación
     * @param _nota tipo de nota sacada 
     * @param _calificacion calificaiom total del alumno
    */
    function califica(address _direccionAlumno, uint _indiceEvaluacion, tipoNota _nota, uint _calificacion) soloProfesor soloAbierta public{
        calificaciones[_direccionAlumno][_indiceEvaluacion] = Nota(_nota,_calificacion*100);
    }
    /**
     * Devuelve el tipo de nota y la calificacion que ha sacado el alumno que invoca el metodo en 
    la evaluacion pasada como parametro.
     * 
     * @param _indiceEvaluacion Indice de una evaluacion en el array de evaluaciones.
     * 
     * @return _tipo         El tipo de nota que ha sacado el alumno.
     * @return _calificacion La calificacion que ha sacado el alumno.
     */ 
    function miNota(uint _indiceEvaluacion) soloMatriculados public view returns (tipoNota _tipo, uint _calificacion) {
        
        require(_indiceEvaluacion < evaluaciones.length, "El indice de la evaluacion no existe.");
        
        Nota memory nota = calificaciones[msg.sender][_indiceEvaluacion];
        
        _tipo = nota.tipo;
        _calificacion = nota.calificacion;
    }
    /**
     * Modificador para que solo pueda ser utilizado por el creador del contrato.
     * 
     * 
    */
    modifier soloOwner() {
        require(msg.sender == owner, "Solo permitido al profesor que creo el contrato");
        _;
    }
    /**
     * Modificador para que solo pueda ser utilizado por el coordinador del contrato.
     * 
     * 
    */
    modifier soloCoordinador() {
        require(msg.sender == coordinador, "Solo permitido al coordinador de la asignatura");
        _;
    }
    /**
     * Modificador para que solo pueda ser utilizado por un profesor de la asignatura.
     * 
     * 
    */
    modifier soloProfesor() {
        bytes memory bn = bytes(datosProfesor[msg.sender]);
        require(bn.length != 0, "Solo permitido a profesores de la asignatura");
        _;
    }
    /**
     * Modificador para que una funcion solo la pueda ejecutar un alumno matriculado.
     */
    modifier soloMatriculados() {
        bytes memory bDNI = bytes(datosAlumno[msg.sender].DNI);
        require(bDNI.length != 0, "Solo permitido a alumnos matriculados");
        _;
    }
    /**
     * Modificador para que una funcion solo la pueda ejecutar un alumno NO matriculado.
     */
    modifier noMatriculados() {
        bytes memory bDNI = bytes(datosAlumno[msg.sender].DNI);
        require(bDNI.length == 0, "Solo permitido a alumnos NO matriculados");
        _;
    }        
    /**
     * Modificador para que una función solo se pueda ejecutar si la asigantura esta abierta
    */
    modifier soloAbierta(){
        require(!cerrada ,"La asignatura se encuentra cerrada");
        _;
    }
    /**
     * No se permite la recepcion de dinero.
     */
    receive() external payable {
        revert("No se permite la recepcion de dinero.");
    }
}