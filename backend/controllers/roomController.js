const Room = require('../models/roomModel');

// Room ki amenities aur JSON formatting format karne ka helper
const formatRoomData = (room) => {
  if (room && room.amenities && typeof room.amenities === 'string') {
    try {
      room.amenities = JSON.parse(room.amenities);
    } catch (_) {}
  }
  return room;
};

// @desc    Search aur filter parameters ke sath sab rooms lana
// @route   GET /api/rooms
const getRooms = async (req, res, next) => {
  try {
    const filters = {
      search: req.query.search || '',
      room_type: req.query.room_type || '',
      min_price: req.query.min_price ? parseFloat(req.query.min_price) : null,
      max_price: req.query.max_price ? parseFloat(req.query.max_price) : null,
      room_status: req.query.room_status || ''
    };

    const rooms = await Room.findFiltered(filters);
    const formattedRooms = rooms.map(formatRoomData);

    res.status(200).json({ 
      success: true, 
      count: formattedRooms.length, 
      data: formattedRooms 
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Room banana
// @route   POST /api/rooms
const createRoom = async (req, res, next) => {
  try {
    const { room_name, room_type, room_price, room_status, room_description, image_url, amenities } = req.body;

    if (!room_name || !room_type || !room_price) {
      res.status(400);
      throw new Error('Please provide room_name, room_type, and room_price');
    }

    const roomId = await Room.create({
      room_name,
      room_type,
      room_price,
      room_status,
      room_description,
      image_url,
      amenities
    });

    res.status(201).json({
      success: true,
      message: 'Room added successfully',
      data: { 
        room_id: roomId, 
        room_name, 
        room_type, 
        room_price, 
        room_status: room_status || 'available',
        room_description,
        image_url,
        amenities
      }
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Room update karna
// @route   PUT /api/rooms/:id
const updateRoom = async (req, res, next) => {
  try {
    const roomId = req.params.id;
    const { room_name, room_type, room_price, room_status, room_description, image_url, amenities } = req.body;

    const room = await Room.findById(roomId);
    if (!room) {
      res.status(404);
      throw new Error('Room not found');
    }

    await Room.update(roomId, {
      room_name: room_name !== undefined ? room_name : room.room_name,
      room_type: room_type !== undefined ? room_type : room.room_type,
      room_price: room_price !== undefined ? room_price : room.room_price,
      room_status: room_status !== undefined ? room_status : room.room_status,
      room_description: room_description !== undefined ? room_description : room.room_description,
      image_url: image_url !== undefined ? image_url : room.image_url,
      amenities: amenities !== undefined ? amenities : room.amenities
    });

    res.status(200).json({
      success: true,
      message: 'Room updated successfully'
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Room delete karna
// @route   DELETE /api/rooms/:id
const deleteRoom = async (req, res, next) => {
  try {
    const roomId = req.params.id;

    const room = await Room.findById(roomId);
    if (!room) {
      res.status(404);
      throw new Error('Room not found');
    }

    await Room.delete(roomId);

    res.status(200).json({
      success: true,
      message: 'Room deleted successfully'
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getRooms,
  createRoom,
  updateRoom,
  deleteRoom
};
